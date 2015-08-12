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

@end

@implementation PGPermissionGatewayViewController

#pragma mark - View Lifecycle
#pragma mark -

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
    [self dismiss];
}

- (IBAction)allowButtonTapped:(id)sender {
    NSLog(@"Allow Tapped");
    
    [[PGPermissionGateway sharedInstance] requestPermission:self.requestedPermission withCompletionBlock:^(BOOL authorized, NSError *error) {
        DebugLog(@"authorized: %@", authorized ? @"YES" : @"NO");
        if (error) {
            DebugLog(@"Error: %@", error);
        }
        
        [self dismiss];
    }];
}

- (IBAction)denyButtonTapped:(id)sender {
    NSLog(@"Deny Tapped");
    
    [self dismiss];
}

#pragma mark - Private
#pragma mark -

- (void)dismiss {
    NSAssert(self.navigationController != nil, @"NC must be defined");
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Dismissed Permission Gateway");
        
        //    TODO: indicate that the permission was granted or not
    }];
}

@end
