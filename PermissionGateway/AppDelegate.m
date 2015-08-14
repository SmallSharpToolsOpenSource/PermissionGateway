//
//  AppDelegate.m
//  PermissionGateway
//
//  Created by Brennan Stehling on 8/10/15.
//  Copyright (c) 2015 Brennan Stehling. All rights reserved.
//

#import "AppDelegate.h"

#import "Macros.h"

#import <PGPermissionGateway/PGPermissionGateway.h>

@implementation AppDelegate

#pragma mark - Application Lifecycle
#pragma mark -

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    PGPermissionStatus notificationPermissionStatus = [[PGPermissionGatewayManager sharedInstance] statusForRequestedPermission:PGRequestedPermissionNotification];
    if (notificationPermissionStatus == PGPermissionStatusAllowed) {
        // refresh the device token
        [application registerForRemoteNotifications];
    }
    
    return YES;
}

#pragma mark - Remote Notifications
#pragma mark -

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [[PGPermissionGatewayManager sharedInstance] reportNotificationRegisteredWithSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[PGPermissionGatewayManager sharedInstance] reportNotificationDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[PGPermissionGatewayManager sharedInstance] reportNotificationRegistrationError:error];
}

@end
