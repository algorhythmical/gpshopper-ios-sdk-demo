//
//  GPDBeaconOptViewController.m
//  GPShopper-iOS
//
//  Created by Donna on 4/12/15.
//  Copyright (c) 2015 James Lee. All rights reserved.
//

#import "GPDBeaconOptViewController.h"

@interface GPDBeaconOptViewController ()

@end

@implementation GPDBeaconOptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.optInSwitch addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.optInSwitch setOn:[SCBeaconDeviceManager isOptedIn]];
}

- (void)stateChanged:(UISwitch*)switchState {
    if ([switchState isOn]) {
        [SCBeaconDeviceManager optIn:YES];
    }
    else {
        [SCBeaconDeviceManager optIn:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
