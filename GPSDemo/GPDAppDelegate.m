//
//  GPDAppDelegate.m
//  GPSDemo
//
//  Created by James Lee on 5/2/14.
//  Copyright (c) 2014 James Lee. All rights reserved.
//

#import "GPDAppDelegate.h"

#import "TWTSideMenuViewController.h"

#import "GPDConstants.h"
#import "GPDSideMenuViewController.h"
#import "GPDWebViewController.h"

#import "GPDHomeViewController.h"
#import "GPDBrowseViewController.h"
#import "GPDStoresViewController.h"
#import "GPDEventsViewController.h"
#import "GPDPDPViewController.h"
#import "GPDPromoViewController.h"
#import "GPDPromoDetailViewController.h"
#import "GPDMoreViewController.h"
#import "GPDInStoreViewController.h"
#import "GPDShoppingListViewController.h"
#import "GPDProfileViewController.h"
#import "GPDBeaconOptViewController.h"

@interface GPDAppDelegate ()

@property (strong, nonatomic) GPDSideMenuViewController *menuViewController;
@property (strong, nonatomic) TWTSideMenuViewController *mainViewController;

@property (strong, nonatomic) GPDHomeViewController *homeViewController;
@property (strong, nonatomic) GPDBrowseViewController *browseViewController;
@property (strong, nonatomic) GPDStoresViewController *storesViewController;
@property (strong, nonatomic) GPDEventsViewController *eventsViewController;
@property (strong, nonatomic) GPDPromoViewController *promoViewController;
@property (strong, nonatomic) GPDMoreViewController *moreViewController;
@property (strong, nonatomic) GPDInStoreViewController *inStoreViewController;
@property (strong, nonatomic) GPDProfileViewController *profileViewController;
@property (strong, nonatomic) GPDShoppingListViewController *shoppingListViewController;
@property (strong, nonatomic) SCWebTrackingEventBatchSender *batchSender;


@end
@implementation GPDAppDelegate

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureForSDK];
    
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceAlert];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], [GPDSideMenuViewController class], nil] setTextColor:[UIColor whiteColor]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.tabBarController = [self tabBarWithViewControllers:[self viewControllers]];
    [self.tabBarController setSelectedIndex:0];
    
    UIViewController *rootController = nil;
    BOOL sideMenu = YES;
    
    if (sideMenu) {
        rootController = [self sideMenuWithViewControllers:[self viewControllers]];
    } else {
        rootController = self.tabBarController;
    }
    
    self.window.backgroundColor = kGPDBlueColor;
    [self.window setRootViewController:rootController];
    [self.window makeKeyAndVisible];
    
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (nil != remoteNotif)
    {
        NSLog(@"We started with a Remote Notification of [%@]", remoteNotif);
        [SCPushNotificationHandler handleRemoteNotification:remoteNotif delegate:self];
    }
    NSDictionary *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (nil != localNotif)
    {
        NSLog(@"We started with a Local Notification of [%@]", localNotif);
        [SCPushNotificationHandler handleLocalNotification:localNotif delegate:self];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways)
    {
        [CustomAlertView showSimpleAlertWithTitle:nil message:@"You must allow for Locations!"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                    UIApplicationOpenSettingsURLString]];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [GPSSDKConfiguration handleURL: url];
}

#pragma mark Configuration

- (void)configureForSDK
{
    [GPSSDKConfiguration configureForSDKWithDelegate:self];
    [GPSSDKConfiguration configureBannerManager:self];
    [BannerView setBannerActionDelegate:self];
    [SCGeoFenceManager configureForDelegate:self];
    [SCBeaconDeviceManager startBeaconDeviceManagerForDelegate:self reqireOptIn:NO];
    [SCBrowse configureBrowse:self];
    [[SCBrowse defaultHierarchy] fetch];
    self.batchSender = [[SCWebTrackingEventBatchSender alloc] init];
    [SCWebTracking addTrackingEventSender:self.batchSender];
    
    // GPSSDKConfiguration -
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(reactToNotificationAcceptedNotification:)
     name: kSCPushNotificationHandlerAcceptedNotification
     object: nil];
}


#pragma mark PushNotificationDelegate : BannerActionDelegate

- (void)pushNotificationGotoHomePage
{
    [self.menuViewController setActiveViewController:self.homeViewController];
}

- (void)bannerGotoWapPageWithUrl:(NSString *)url
{
    NSURL *path = [NSURL URLWithString:url];
    GPDWebViewController *vc = [GPDWebViewController new];
    vc.url = path;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    nav.modalPresentationStyle = UIModalPresentationPopover;
    
    [self.mainViewController presentViewController:nav animated:YES completion:nil];
}

- (void)bannerGotoSectionNamed:(NSString *)name
{
    UIViewController *targetVC;
    for (UIViewController *vc in self.viewControllers) {
        if ([vc.title caseInsensitiveCompare:name] == NSOrderedSame) {
            targetVC = vc;
            break;
        }
    }
    [self.menuViewController setActiveViewController:targetVC];
}

- (void)bannerGotoLandingPageForGrpid:(uint64_t)grpid supplemental:(NSDictionary *)ss
{
    GPDPDPViewController *vc = [GPDPDPViewController new];
    vc.grpid = grpid;
    [self.menuViewController setActiveViewController:vc];
}

- (void)bannerGotoSearchResultsForQuery:(NSString *)query
{
    [self.menuViewController goToSearchForQuery:query];
}

- (void)bannerGotoPromoPageForGrpid:(uint64_t)grpid
{
    GPDPromoDetailViewController *vc = [GPDPromoDetailViewController new];
    vc.grpid = grpid;
    [self.menuViewController setActiveViewController:vc];
}

- (void)bannerGotoEventForEventid:(uint64_t)i
{
    
}

- (void)bannerView:(BannerView *)v willPerformActionForChildBanner:(SCChildBanner *)cb parentBanner:(Banner *)b
{
    
}

- (void)bannerView:(BannerView *)v didPerformActionForChildBanner:(SCChildBanner *)cb parentBanner:(Banner *)b
{
    
}

-(void)bannerGotoCustomAction: (NSString *)scriptAction
{
    
}


#pragma mark - GPSSDKConfigurationDelegate

-(void)locationUpdated:(SCGeoLocation *)location
{
    NSLog(@"Location was updated to %lf, %lf", location.latlon.latitude, location.latlon.longitude);
    NSDictionary *userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithDouble:location.latlon.latitude], @"latitude",
                                  [NSNumber numberWithDouble:location.latlon.longitude], @"longitude",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:GPDCurrentLocationDidUpdateNotification
                                                        object:self
                                                      userInfo:userInfoDict];
}

#pragma mark - Delegate methods: SCBeaconDeviceManagerDelegate  // All of the methods in the protocol are optional.


-(void)scBeaconDeviceManager:(SCBeaconDeviceManager *)manager didEnterRegion:(CLBeaconRegion *)region
{
    NSLog(@"We didEnterRegion [%@]", region.identifier);
}

-(void)scBeaconDeviceManager:(SCBeaconDeviceManager *)manager didExitRegion:(CLBeaconRegion *)region
{
    NSLog(@"We didExitRegion [%@]", region.identifier);
}

-(void)scBeaconDeviceManager:(SCBeaconDeviceManager *)manager receivedOptIn:(GPSSDKOptIn *)optin
{
    /**
     This method only gets called if -
     1) Beacons are enabled
     2) The value for optin has not been set
     3) requireOptIn was set to YES when starting the beaconManager
     **/
    
    // The following method can be used to opt-in or opt-out from receiving beacon notifications (value is persisted in NSUserDefaults)
    [SCBeaconDeviceManager optIn:YES];
    NSLog(@"You have opted in to receive beacon notifications");
}

-(void)scBeaconDeviceManagerWasUpdated:(SCBeaconDeviceManager *)manager
{
    // This method gets called whenever beacons have been enabled or disabled in the console.
    NSLog(@"The Beacons feature has been turned %@", [manager isEnabled] ? @"ON" : @"OFF");
}



#pragma mark View Heirarchy

- (NSArray *)viewControllers
{
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:
                                self.homeViewController,
                                self.browseViewController,
                                self.inStoreViewController,
                                self.storesViewController,
                                self.eventsViewController,
                                self.profileViewController,
                                self.shoppingListViewController,
                                self.moreViewController,
                                nil];
    return viewControllers;
}

- (GPDHomeViewController *)homeViewController
{
    if (!_homeViewController) {
        _homeViewController = [GPDHomeViewController new];
        _homeViewController.title = @"Home";
        _homeViewController.tabBarItem.image = [UIImage imageNamed:@"menu_home"];
    }
    return _homeViewController;
}

- (GPDBrowseViewController *)browseViewController
{
    if (!_browseViewController) {
        _browseViewController = [GPDBrowseViewController new];
        _browseViewController.title = @"Shop";
        _browseViewController.tabBarItem.image = [UIImage imageNamed:@"menu_browse"];
    }
    return  _browseViewController;
}

- (GPDStoresViewController *)storesViewController
{
    if (!_storesViewController) {
        _storesViewController = [GPDStoresViewController new];
        _storesViewController.title = @"Stores";
        _storesViewController.tabBarItem.image = [UIImage imageNamed:@"menu_stores"];
    }
    return  _storesViewController;
}

- (GPDEventsViewController *)eventsViewController
{
    if (!_eventsViewController) {
        _eventsViewController = [GPDEventsViewController new];
        _eventsViewController.title = @"Events";
        _eventsViewController.tabBarItem.image = [UIImage imageNamed:@"menu_cart"];
    }
    return _eventsViewController;
}

- (GPDPromoViewController *)promoViewController
{
    if (!_promoViewController) {
        _promoViewController = [GPDPromoViewController new];
        _promoViewController.title = @"Promos";
    }
    return _promoViewController;
}

- (GPDProfileViewController *)profileViewController
{
    if (!_profileViewController) {
        _profileViewController = [GPDProfileViewController new];
        _profileViewController.title = @"Profile";
    }
    return _profileViewController;
}


- (GPDShoppingListViewController *)shoppingListViewController
{
    if (!_shoppingListViewController) {
        _shoppingListViewController = [GPDShoppingListViewController new];
        _shoppingListViewController.title = @"Shopping List";
    }
    return _shoppingListViewController;
}

- (GPDMoreViewController *)moreViewController
{
    if (!_moreViewController) {
        _moreViewController = [GPDMoreViewController new];
        _moreViewController.title = @"More";
        
        GPDWebViewController *webVC = [GPDWebViewController new];
        NSURL *url = [NSURL URLWithString:@"http://www.gpshopper.com"];
        webVC.url = url;
        webVC.title = @"About Us";

        GPDBeaconOptViewController *beaconOptVC = [[GPDBeaconOptViewController alloc] init];
        beaconOptVC.title = @"Beacon Opt In";

        _moreViewController.viewControllers = @[webVC, beaconOptVC];
    }
    return _moreViewController;
}

- (GPDInStoreViewController *)inStoreViewController
{
    if (!_inStoreViewController) {
        _inStoreViewController = [GPDInStoreViewController new];
        _inStoreViewController.title = @"In Store";
    }
    return _inStoreViewController;
}

- (UITabBarController *)tabBarWithViewControllers:(NSArray *)viewControllers
{
    NSMutableArray *navControllers = [[NSMutableArray alloc] init];
    for (UIViewController *vc in viewControllers) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBar.translucent = NO;
        [navControllers addObject:nav];
    }
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:navControllers];


    return  tabBarController;
}

- (TWTSideMenuViewController *)sideMenuWithViewControllers:(NSArray *)viewControllers
{
    self.menuViewController = [GPDSideMenuViewController new];
    [self.menuViewController setViewControllers:viewControllers];
    self.mainViewController = [[TWTSideMenuViewController alloc] initWithMenuViewController:self.menuViewController mainViewController:[[UINavigationController alloc] initWithRootViewController:self.homeViewController]];
    self.mainViewController.shadowColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.mainViewController.edgeOffset = UIOffsetMake(15.0, 0);
    self.mainViewController.zoomScale = 0.5;
    self.mainViewController.animationDuration = 0.3;
    [self.mainViewController setDelegate:self.menuViewController];
    self.mainViewController.animationType = TWTSideMenuAnimationTypeFadeIn;
    return self.mainViewController;
}

#pragma mark APNS

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    [SCGeoFenceManager didRegisterForRemoteNotificationsWithDeviceToken:devToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    [SCGeoFenceManager didFailToRegisterForRemoteNotificationsWithError:err];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [SCPushNotificationHandler handleRemoteNotification:userInfo delegate:self];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [SCPushNotificationHandler handleLocalNotification:[notification userInfo] delegate:self];
}

#pragma mark BrowseDelegate

-(void)browse:(SCBrowse *)browse updatedNode:(SCBrowseNode *)node
{
    self.browseViewController.node = node;
}

#pragma mark - Delegate methods: SCGeoFenceManagerDelegate

- (void)geoFenceManager:(SCGeoFenceManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"We entered region [%@]", region.identifier);
}

- (void)geoFenceManager:(SCGeoFenceManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"We exited region [%@]", region.identifier);
}

#pragma mark NSNotificationCenter

- (void)reactToNotificationAcceptedNotification:(NSNotification *)n
{
    if (![[NSThread currentThread] isMainThread])
    {
        [self performSelectorOnMainThread:@selector(reactToNotificationAcceptedNotification:) withObject:n waitUntilDone:NO];
        return;
    }
    
    // This is the userInfo of the original Notification
    //    NSDictionary *userInfo = (NSDictionary *)[n userInfo];
    
}

@end
