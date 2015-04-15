//
//  GPDStoresViewController.h
//  GPSDemo
//
//  Created by James Lee on 5/10/14.
//  Copyright (c) 2014 James Lee. All rights reserved.
//

#import "GPDViewController.h"
@import MapKit;

typedef enum : NSUInteger {
    GPDStoresMapMode,
    GPDStoresListMode,
} GPDStoresMode;

extern NSString* const GPDCurrentLocationDidUpdateNotification;

@interface GPDStoresViewController : GPDViewController <MKMapViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *listView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (assign, nonatomic) GPDStoresMode viewMode;

@property (strong, nonatomic) CLLocation *lastSearchedLocation;

@end
