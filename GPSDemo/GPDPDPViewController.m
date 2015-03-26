//
//  GPDPDPViewController.m
//  GPSDemo
//
//  Created by James Lee on 5/14/14.
//  Copyright (c) 2014 James Lee. All rights reserved.
//

#import "GPDPDPViewController.h"
#import "GPDImageFetcher.h"


@interface GPDPDPViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) SCLocalizedProductFetcher *productFetcher;
@property (weak, nonatomic) IBOutlet UIButton *shoppingListButton;
@property (weak, nonatomic) IBOutlet UIButton *applePayButton;
@property (strong, nonatomic) NSArray *supportedPaymentNetworks;

@end

@implementation GPDPDPViewController

- (void)viewDidLoad
{
    self.supportedPaymentNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex];

    [super viewDidLoad];
    [self reloadAll];
    
    self.productFetcher = [[SCLocalizedProductFetcher alloc] initWithListener:self];
    self.shoppingListButton.layer.cornerRadius = 2.f;
    
    if (self.grpid) {
        [self.productFetcher fetchLocalizedProductForGrpid:self.grpid zipcode:@"USEGPS"];
    } else if (self.product) {
        [self.productFetcher fetchLocalizedProductForGrpid:self.product.grpid zipcode:@"USEGPS"];
    }
    
    self.applePayButton.hidden = ![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:self.supportedPaymentNetworks];
}


- (void)reloadAll
{
    id<SCBaseProduct> product = self.localInstance ? self.localInstance : self.product;
    
    
    NSString *url = [product urlForImageWithinSize:CGSizeMake(640, 640)];
    UIImage *cachedImage = [[GPDImageFetcher sharedInstance] cachedImageForURL:url];
    if (cachedImage) {
        self.imageView.image = cachedImage;
    } else {
        [[GPDImageFetcher sharedInstance] fetchImageForURL:url cache:YES completion:^(UIImage *image) {
            self.imageView.image = cachedImage;
        }];
    }
    self.titleLabel.text = product.productName ? product.productName : @"";
    self.detailLabel.text = [NSString stringWithFormat:@"%@\n\n%@",
                             product.shortDescription ? product.shortDescription : @"",
                             product.longDescription ? product.longDescription : @""];
    
    
    InstanceSpecificInfo *firstInstance = self.localInstance ? [self.localInstance.nearbyInstances firstObject] : [self.product.productInstances firstObject];
    NSNumber *price = [NSNumber numberWithUnsignedLongLong:firstInstance.price/100.f];
    NSString *priceString = [NSString stringWithFormat:@"%@",
                            [NSNumberFormatter localizedStringFromNumber:price numberStyle:NSNumberFormatterCurrencyStyle]];
    self.priceLabel.text = priceString ? priceString : @"";
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)addToShoppingList:(id)sender {
    SCShoppingList *shoppingList = [SCShoppingList defaultList];

        SCShoppingListItemId *i = [[SCShoppingListItemId alloc] initWithGrpid:self.product.grpid piid:0];
    SCShoppingListItemPrimaryUpdate *update = [[SCShoppingListItemPrimaryUpdate alloc] initWithItemId:i localBaseProduct:self.product message:self.product.productName mslSupplemental:@{} state:SCShoppingListItemTypeDefault];
    [shoppingList stageUpdate:update];
}

- (IBAction)checkOut:(id)sender
{
    if([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:self.supportedPaymentNetworks]) {
        id<SCBaseProduct> product = self.localInstance ? self.localInstance : self.product;
        InstanceSpecificInfo *firstInstance = self.localInstance ? [self.localInstance.nearbyInstances firstObject] : [self.product.productInstances firstObject];
        NSNumber *price = [NSNumber numberWithUnsignedLongLong:firstInstance.price/100.f];
        PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
        PKPaymentSummaryItem *productPayment = [PKPaymentSummaryItem summaryItemWithLabel:product.productName ? product.productName : @""
                                                                            amount:[NSDecimalNumber decimalNumberWithString:[price stringValue]]];
        
        
        request.paymentSummaryItems = @[productPayment];
        request.countryCode = @"US";
        request.currencyCode = @"USD";
        request.supportedNetworks = self.supportedPaymentNetworks;
        request.merchantIdentifier = @"merchant.com.gpshopper";
        request.merchantCapabilities = PKMerchantCapabilityEMV | PKMerchantCapability3DS;
        
        PKPaymentAuthorizationViewController *paymentPane = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        
        if (paymentPane)
        {
            paymentPane.delegate = self;
            [self presentViewController:paymentPane animated:TRUE completion:nil];
        }
        else
        {
            [CustomAlertView showSimpleAlertWithTitle:nil message:@"This device not configured for Apple Pay."];
        }
        
    } else {
        [CustomAlertView showSimpleAlertWithTitle:nil message:@"This device cannot make payments using Apple Pay."];
    }
}


#pragma mark SCLocalizedProductFetcherListener
-(void)scLocalizedProductFetcher: (SCLocalizedProductFetcher *)f
                  fetchedProduct: (SCLocalizedProduct *)p
{
    self.localInstance = p;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadAll];
    });

}

-(void)scLocalizedProductFetcherFailed: (SCLocalizedProductFetcher *)f {}


+ (void)initialize
{
    NSArray *ri_image_sizes = @[@[@480,@640]];
    [SCLocalizedProductFetcher setImageSizes:ri_image_sizes];
}

#pragma mark PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    NSLog(@"Payment was authorized: %@", payment);
    
    // do an async call to the server to complete the payment.
    // See PKPayment class reference for object parameters that can be passed
    BOOL asyncSuccessful = FALSE;
    
    // When the async call is done, send the callback.
    // Available cases are:
    //    PKPaymentAuthorizationStatusSuccess, // Merchant auth'd (or expects to auth) the transaction successfully.
    //    PKPaymentAuthorizationStatusFailure, // Merchant failed to auth the transaction.
    //
    //    PKPaymentAuthorizationStatusInvalidBillingPostalAddress,  // Merchant refuses service to this billing address.
    //    PKPaymentAuthorizationStatusInvalidShippingPostalAddress, // Merchant refuses service to this shipping address.
    //    PKPaymentAuthorizationStatusInvalidShippingContact        // Supplied contact information is insufficient.
    
    if(asyncSuccessful) {
        completion(PKPaymentAuthorizationStatusSuccess);
        
        // do something to let the user know the status
        
        NSLog(@"Payment was successful");
    } else {
        completion(PKPaymentAuthorizationStatusFailure);
        
        // do something to let the user know the status
        
        NSLog(@"Payment was unsuccessful");
    }
    
}

// The delegate is responsible for dismissing the view controller in this method.
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

// Sent when the user has selected a new shipping method.  The delegate should determine
// shipping costs based on the shipping method and either the shipping address supplied in the original
// PKPaymentRequest or the address fragment provided by the last call to paymentAuthorizationViewController:
// didSelectShippingAddress:completion:.
//
// The delegate must invoke the completion block with an updated array of PKPaymentSummaryItem objects.
//
// The delegate will receive no further callbacks except paymentAuthorizationViewControllerDidFinish:
// until it has invoked the completion block.
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                   didSelectShippingMethod:(PKShippingMethod *)shippingMethod
                                completion:(void (^)(PKPaymentAuthorizationStatus status, NSArray *summaryItems))completion
{
    
}

// Sent when the user has selected a new shipping address.  The delegate should inspect the
// address and must invoke the completion block with an updated array of PKPaymentSummaryItem objects.
//
// The delegate will receive no further callbacks except paymentAuthorizationViewControllerDidFinish:
// until it has invoked the completion block.
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                  didSelectShippingAddress:(ABRecordRef)address
                                completion:(void (^)(PKPaymentAuthorizationStatus status, NSArray *shippingMethods, NSArray *summaryItems))completion
{
    
}


@end
