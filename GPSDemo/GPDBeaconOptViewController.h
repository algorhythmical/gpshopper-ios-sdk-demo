//
//  GPDBeaconOptViewController.h
//  GPShopper-iOS
//
//  Created by Donna on 4/12/15.
//  Copyright (c) 2015 James Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const GPDBeaconDidOptInNotification;
extern NSString* const GPDBeaconDidOptOutNotification;

@interface GPDBeaconOptViewController : UIViewController

@property(weak, nonatomic) IBOutlet UISwitch* optInSwitch;

@end
