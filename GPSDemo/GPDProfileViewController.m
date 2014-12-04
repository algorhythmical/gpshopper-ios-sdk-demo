//
//  GPDProfileViewController.m
//  GPShopper-iOS
//
//  Created by Matthew Reed on 10/28/14.
//  Copyright (c) 2014 James Lee. All rights reserved.
//

#import "GPDProfileViewController.h"
#import "GPDLoginViewController.h"

@interface GPDProfileViewController ()
{
    SCProfile *profile;
    SCSession *session;
    SCRegistrationState *state;
}

@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UIButton *loginLogoutButton;

@end

@implementation GPDProfileViewController

@synthesize firstNameLabel;
@synthesize lastNameLabel;
@synthesize emailLabel;
@synthesize loginLogoutButton;


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        profile = [SCProfile defaultProfile];
        session = [SCSession defaultSession];
        state = [SCRegistrationState defaultState];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserverForName:@"scsession_updated" object:session queue:nil usingBlock:^(NSNotification *note) {
        if (!session.exists) {
            [loginLogoutButton setTitle:@"Login" forState:UIControlStateNormal];
            [profile clear];
            [state clear];
            firstNameLabel.hidden = YES;
            lastNameLabel.hidden = YES;
            emailLabel.hidden = YES;
            firstNameLabel.text = nil;
            lastNameLabel.text = nil;
            emailLabel.text = nil;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You have been logged out" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            [loginLogoutButton setTitle:@"Logout" forState:UIControlStateNormal];
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"scsession_updated" object:session];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (profile.fetched) {
        firstNameLabel.hidden = NO;
        lastNameLabel.hidden = NO;
        emailLabel.hidden = NO;
        firstNameLabel.text = profile.firstName;
        lastNameLabel.text = profile.lastName;
        emailLabel.text = profile.email;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginLogoutButtonPressed:(id)sender {
    if (session.exists) {
        [session destroy];
    } else {
        [self showLogin];
    }
}

- (void)showLogin {
    GPDLoginViewController *vc = [[GPDLoginViewController alloc] initWithNibName:@"GPDLoginViewController" bundle:nil];
    vc.title = @"Login";
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
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
