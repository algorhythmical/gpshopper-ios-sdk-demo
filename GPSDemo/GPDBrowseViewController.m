//
//  GPDBrowseViewController.m
//  GPSDemo
//
//  Created by James Lee on 5/10/14.
//  Copyright (c) 2014 James Lee. All rights reserved.
//

#import "GPDBrowseViewController.h"
#import "GPDSearchViewController.h"

@interface GPDBrowseViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation GPDBrowseViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setTableFooterView:[UIView new]];
    [self.tableView registerNib:[UINib nibWithNibName:@"GPDBrowseNoResultsCell" bundle:nil]
         forCellReuseIdentifier:@"GPDBrowseNoResultsCell"];
    
    if (!self.node) {
        [self.spinner startAnimating];
    }
}

- (void)setNode:(SCBrowseNode *)node
{
    _node = node;
    if (self.tableView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.spinner stopAnimating];
        });
    }
    // This has the side effect of also displaying the count in the breadcrumb when drilling down.
    self.title = [self.title stringByAppendingString:[NSString stringWithFormat:@" (%lu)", node.children.count]];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.node) {
        return 0;
    }
    NSInteger numChildren = [self.node.children count];
    return (numChildren >=1) ? numChildren : 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.node children] count] == 0) {
        return [self.tableView dequeueReusableCellWithIdentifier:@"GPDBrowseNoResultsCell"];
    }
    NSString *reuseIdentifier = @"browse_cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    SCBrowseNode *childNode = [self.node.children objectAtIndex:indexPath.row];
    [cell.textLabel setText:childNode.title];
    
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.node children] count] == 0) {
        return;
    }
    
    SCBrowseNode *childNode = [self.node.children objectAtIndex:indexPath.row];
    if (childNode && [[childNode children] count]) {
        GPDBrowseViewController *vc = [GPDBrowseViewController new];
        [vc setTitle:childNode.title];
        [vc setNode:childNode];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (childNode && [childNode searchTerm]) {
        GPDSearchViewController *vc = [GPDSearchViewController new];
        [vc setSearchQuery:[childNode searchTerm]];
        [vc setTitle:childNode.title];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    GPDSearchViewController *vc = [GPDSearchViewController new];
    [vc setSearchQuery:searchBar.text];
    [self.navigationController pushViewController:vc animated:YES];
}

//#pragma mark SCStartupSequenceDelegate
//-(void)scStartupSequenceUpdatedReachability: (SCStartupSequence *)s {}
//-(void)scStartupSequenceUpdatedBrowse: (SCStartupSequence *)s
//{
//    SCBrowseNode *node = [[SCBrowse defaultHierarchy] rootNode];
//    if (node) {
//        [self setNode:node];
//        [self.spinner stopAnimating];
//    }
//}
//-(void)scStartupSequenceUpdatedLocation: (SCStartupSequence *)s {}

@end
