//
//  GPDMoreViewController.m
//  GPSDemo
//
//  Created by James Lee on 10/10/14.
//  Copyright (c) 2014 James Lee. All rights reserved.
//

#import "GPDMoreViewController.h"
#import "GPDBeaconOptViewController.h"
#import "GPDBeaconOptTableViewCell.h"

@interface GPDMoreViewController ()

@end

@implementation GPDMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"More";
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseID = @"more_cell";
    static NSString *beaconReuseID = @"beacon_cell";
    UITableViewCell *cell = nil;

    if ([[self.viewControllers objectAtIndex:indexPath.row] isKindOfClass:[GPDBeaconOptViewController class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:beaconReuseID];
        if (!cell) {
            cell = [[GPDBeaconOptTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:beaconReuseID];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if ([SCBeaconDeviceManager isOptedIn]) {
            cell.detailTextLabel.text = @"On";
        }
        else {
            cell.detailTextLabel.text = @"Off";
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    UIViewController *vc = self.viewControllers[indexPath.row];
    cell.textLabel.text = vc.title;
    return cell;
}
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *vc = self.viewControllers[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
