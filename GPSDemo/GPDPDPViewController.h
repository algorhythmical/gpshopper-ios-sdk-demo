//
//  GPDPDPViewController.h
//  GPSDemo
//
//  Created by James Lee on 5/14/14.
//  Copyright (c) 2014 James Lee. All rights reserved.
//

#import "GPDViewController.h"
#import <PassKit/PassKit.h>

@interface GPDPDPViewController : GPDViewController <SCLocalizedProductFetcherListener,PKPaymentAuthorizationViewControllerDelegate>

@property (strong, nonatomic) SCSearchResultProduct *product;
@property (strong, nonatomic) SCLocalizedProduct *localInstance;
@property (assign, nonatomic) uint64_t grpid;

@end
