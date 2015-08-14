//
//  PermissionGatewayViewController.m
//  PermissionGateway
//
//  Created by Brennan Stehling on 8/10/15.
//  Copyright (c) 2015 Brennan Stehling. All rights reserved.
//

#import "PGPermissionGatewayViewController.h"

#pragma mark - Class Extension
#pragma mark -

@interface PGPermissionGatewayViewController ()

@property (weak, nonatomic) IBOutlet UILabel *permissionBodyLabel;

@property (weak, nonatomic) IBOutlet UIButton *changeSettingsButton;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIButton *allowButton;
@property (weak, nonatomic) IBOutlet UIButton *denyButton;

@end

@implementation PGPermissionGatewayViewController

#pragma mark - Public
#pragma mark -

+ (void)presentPermissionGetwayInViewController:(UIViewController *)viewController
                         forRequestedPermission:(PGRequestedPermission)requestedPermission
                            withCompletionBlock:(void (^)(BOOL granted, NSError *error))completionBlock {
    PGPermissionStatus status = [[PGPermissionGatewayManager sharedInstance] statusForRequestedPermission:requestedPermission];
    if (status == PGPermissionStatusAllowed) {
        // do nothing
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PermissionGateway" bundle:[NSBundle bundleForClass:[self class]]];
    NSAssert(storyboard != nil, @"Storyboard must be defined");
    
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"PermissionNavigationController"];
    NSAssert([navController.topViewController isKindOfClass:[PGPermissionGatewayViewController class]], @"Top VC must be a Permission Gateway VC");
    PGPermissionGatewayViewController *permissionGatewayVC = (PGPermissionGatewayViewController *)navController.topViewController;
    permissionGatewayVC.requestedPermission = requestedPermission;
    permissionGatewayVC.completionBlock = completionBlock;
    
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [viewController presentViewController:navController animated:YES completion:^{
    }];
}

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];

    PGPermissionStatus status = [[PGPermissionGatewayManager sharedInstance] statusForRequestedPermission:self.requestedPermission];
    
    self.changeSettingsButton.hidden = status != PGPermissionStatusDenied;
    self.buttonsView.hidden = status == PGPermissionStatusDenied;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *titleText = nil;
    NSString *bodyText = nil;
    
    switch (self.requestedPermission) {
        case PGRequestedPermissionPhoto:
            titleText = NSLocalizedString(@"Photo Permission Title", @"Photo");
            bodyText = NSLocalizedString(@"Photo Permission Body", @"Photo");
            break;
        case PGRequestedPermissionCamera:
            titleText = NSLocalizedString(@"Camera Permission Title", @"Camera");
            bodyText = NSLocalizedString(@"Camera Permission Body", @"Camera");
            break;
        case PGRequestedPermissionMicrophone:
            titleText = NSLocalizedString(@"Microphone Permission Title", @"Microphone");
            bodyText = NSLocalizedString(@"Microphone Permission Body", @"Microphone");
            break;
        case PGRequestedPermissionNotification:
            titleText = NSLocalizedString(@"Notification Permission Title", @"Notification");
            bodyText = NSLocalizedString(@"Notification Permission Body", @"Notification");
            break;
        case PGRequestedPermissionContacts:
            titleText = NSLocalizedString(@"Contacts Permission Title", @"Contacts");
            bodyText = NSLocalizedString(@"Contacts Permission Body", @"Contacts");
            break;
        case PGRequestedPermissionLocation:
            titleText = NSLocalizedString(@"Location Permission Title", @"Location");
            bodyText = NSLocalizedString(@"Location Permission Body", @"Location");
            break;
            
        default:
            break;
    }
    
    self.title = titleText;
    self.permissionBodyLabel.text = bodyText;
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissModal];
}

- (IBAction)changeSettingsButtonTapped:(id)sender {
    NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:appSettings];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self dismissModal];
    });
}


- (IBAction)allowButtonTapped:(id)sender {
    NSLog(@"Allow Tapped");
    
    [[PGPermissionGatewayManager sharedInstance] reportPermissionAllowedAtGateway:self.requestedPermission];
    
    [[PGPermissionGatewayManager sharedInstance] requestPermission:self.requestedPermission withCompletionBlock:^(BOOL authorized, NSError *error) {
#ifndef NDEBUG
        NSLog(@"authorized: %@", authorized ? @"YES" : @"NO");
        if (error) {
            NSLog(@"Error: %@", error);
        }
#endif
        
        [self dismissModal];
    }];
}

- (IBAction)denyButtonTapped:(id)sender {
    NSLog(@"Deny Tapped");
    
    [[PGPermissionGatewayManager sharedInstance] reportPermissionDeniedAtGateway:self.requestedPermission];
    
    [self dismissModal];
}

#pragma mark - Private
#pragma mark -

- (void)dismissModal {
    NSAssert(self.navigationController != nil, @"NC must be defined");
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Dismissed Permission Gateway");
        
        //    TODO: indicate that the permission was granted or not
        
        NSAssert([NSThread isMainThread], @"Must be main thread");
        if (self.completionBlock) {
            PGPermissionStatus status = [[PGPermissionGatewayManager sharedInstance] statusForRequestedPermission:self.requestedPermission];
            BOOL granted = status == PGPermissionStatusAllowed;
            
            self.completionBlock(granted, nil);
        }
    }];
}

@end
