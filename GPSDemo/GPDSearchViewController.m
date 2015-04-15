//
//  GPDSearchViewController.m
//  GPSDemo
//
//  Created by James Lee on 5/14/14.
//  Copyright (c) 2014 James Lee. All rights reserved.
//

#import "GPDSearchViewController.h"
#import "GPDPDPViewController.h"
#import "GPDProductCell.h"
#import "GPDImageFetcher.h"
#import "GPDCollectionViewCell.h"
#import "GPDPDPViewController.h"

@interface GPDSearchViewController () {
    CGFloat _yPos;
    CGFloat _yDelta;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) SCSearchFetcher *searchFetcher;
@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@end

@implementation GPDSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchFetcher = [[SCSearchFetcher alloc] init];
    [self.searchFetcher setListener:self];
    
    SCSearchSpecs *specs = [[SCSearchSpecs alloc] initWithQuery:self.searchQuery
                                location:[[SCSearchLocation alloc] initWithZipcode:@"60605"]
                              constraint:[SCSearchConstraint newDefaultConstraint]
                              pagination:nil
                                  extras:nil];
    [self.searchFetcher fetchList:specs];
    [self.spinner startAnimating];
    if (!self.title) {
        self.title = [NSString stringWithFormat:@"Searching: %@", self.searchQuery];
    }
    [self.collectionView registerNib:[UINib nibWithNibName:@"GPDCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"GPDCollectionViewCell"];
    
//    UIBarButtonItem *toggle = [[UIBarButtonItem alloc] initWithTitle:@"Toggle"
//style:UIBarButtonItemStyleBordered
//                                                              target:self action:@selector(toggleMode)];
//    self.navigationItem.rightBarButtonItem = toggle;
//    UIEdgeInsets inset = self.collectionView.contentInset;
//    inset.top = 64;
//    self.collectionView.contentInset = inset;
}

#pragma mark SCSearchFetcherListener

- (void)scSearchFetcher: (SCSearchFetcher *)fetcher
		   fetchedList: (SearchResultList *)list
			  forSpecs: (SCSearchSpecs *)specs
{
    self.products = [list.products copy];
    [self.collectionView reloadData];
    [self.spinner stopAnimating];
}

- (void)scSearchFetcher: (SCSearchFetcher *)fetcher
 fetchedNoListForSpecs: (SCSearchSpecs *)specs
{
    // No results found
}


#pragma mark UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.products ? [self.products count] : 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GPDCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GPDCollectionViewCell" forIndexPath:indexPath];
    
    SCSearchResultProduct *product = [self.products objectAtIndex:indexPath.row];
    
    InstanceSpecificInfo *firstInstance = [product.productInstances firstObject];
    NSNumber *price = [NSNumber numberWithUnsignedLongLong:firstInstance.price/100.f];
    NSString *priceString = [NSString stringWithFormat:@"%@",
                             [NSNumberFormatter localizedStringFromNumber:price numberStyle:NSNumberFormatterCurrencyStyle]];
    NSArray *labelStrings = [NSArray arrayWithObjects:product.productName,priceString ? priceString : @"",nil];
   cell.titleLabel.text = [labelStrings componentsJoinedByString:@"\n"];

    NSString *url = [product urlForImageWithinSize:CGSizeMake(480, 640)];
    UIImage *cachedImage = [[GPDImageFetcher sharedInstance] cachedImageForURL:url];
    
    if (cachedImage) {
        cell.imageView.image = cachedImage;
        cell.imageView.alpha = 1.0;
    } else {
        cell.imageView.alpha = 0.0;
        if (collectionView.dragging == NO && collectionView.decelerating == NO) {
            [self loadImageURL:url forIndex:indexPath];
        }
    }
    
    return cell;

}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GPDPDPViewController *vc = [GPDPDPViewController new];
    
    SCSearchResultProduct *product = [self.products objectAtIndex:indexPath.row];
    [vc setProduct:product];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float velocity = _yPos - scrollView.contentOffset.y;
    _yPos = scrollView.contentOffset.y;
    _yDelta += velocity;
    
    if (fabsf(velocity) < 5 && abs(_yDelta) > 20) {
        [self loadImagesForOnscreenRows];
        _yDelta = 0;
    }
}

- (void)scrollViewDidEndDecelerating
{
    [self loadImagesForOnscreenRows];
}

- (void)loadImagesForOnscreenRows
{
    NSArray *visiblePaths = [self.collectionView indexPathsForVisibleItems];
    
    for (NSIndexPath *indexPath in visiblePaths)
    {
        SCSearchResultProduct *product = [self.products objectAtIndex:indexPath.row];
        NSString *url = [product urlForImageWithinSize:CGSizeMake(480, 640)];
        
        UIImage *cachedImage = [[GPDImageFetcher sharedInstance] cachedImageForURL:url];
        if (!cachedImage) {
            [self loadImageURL:url forIndex:indexPath];
        }
    }
}

- (void)loadImageURL:(NSString *)url forIndex:(NSIndexPath *)indexPath
{
    // Check if product has url
    if (!url.length) {
        return;
    }
    
    [[GPDImageFetcher sharedInstance]
     fetchImageForURL:url
     cache:YES
     completion:^(UIImage *image) {
         if (image) {
             GPDCollectionViewCell *cell = (GPDCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
             dispatch_async(dispatch_get_main_queue(), ^{
                 cell.imageView.image = image;
                 [UIView animateWithDuration:1.0 animations:^{
                     cell.imageView.alpha = 1.0;
                 }];
             });
         }
     }];
}

- (void)toggleMode
{
    self.displayMode = (self.displayMode == GPDSearchDisplayTile) ? GPDSearchDisplayFull : GPDSearchDisplayTile;
}

- (void)setDisplayMode:(GPDSearchDisplayMode)displayMode
{
    _displayMode = displayMode;
    [self.collectionView performBatchUpdates:^{
        if (self.displayMode == GPDSearchDisplayTile) {
            self.flowLayout.itemSize = CGSizeMake(floorf(self.view.bounds.size.width/2.f), floorf(self.view.bounds.size.height/2.f));
            [self.collectionView setCollectionViewLayout:self.flowLayout animated:YES];
            self.collectionView.pagingEnabled = NO;
        } else {
            self.flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width/1.f, self.view.bounds.size.height/1.f);
            [self.collectionView setCollectionViewLayout:self.flowLayout animated:YES];
            self.collectionView.pagingEnabled = YES;

        }

    } completion:nil];
}

+ (void)initialize
{
    NSArray *ri_image_sizes = @[@[@480,@640]];
    [SCSearchFetcher setImageSizes:ri_image_sizes];
}
@end
