//
//  PermissionsGateway.h
//  PermissionGateway
//
//  Created by Brennan Stehling on 8/10/15.
//  Copyright (c) 2015 Brennan Stehling. All rights reserved.
//

@import Foundation;
@import UIKit;

#import "Macros.h"

// Requested Permission
typedef NS_ENUM(NSUInteger, PGRequestedPermission) {
    PGRequestedPermissionNone = 0,
    PGRequestedPermissionPhoto = 1,
    PGRequestedPermissionCamera = 2,
    PGRequestedPermissionMicrophone = 3,
    PGRequestedPermissionNotification = 4,
    PGRequestedPermissionContacts = 5,
    PGRequestedPermissionLocation = 6
};

// Permission Status
typedef NS_ENUM(NSUInteger, PGPermissionStatus) {
    PGPermissionStatusNone = 0,
    PGPermissionStatusGatewayDenied = 1,
    PGPermissionStatusAllowed = 2,
    PGPermissionStatusDenied = 3
};

// Prompt Status
typedef NS_ENUM(NSUInteger, PGPromptStatus) {
    PGPromptStatusNone = 0,
    PGPromptStatusAccepted = 1,
    PGPromptStatusDeclined = 2
};

@interface PGPermissionGateway : NSObject

+ (instancetype)sharedInstance;

- (PGPermissionStatus)statusForRequestedPermission:(PGRequestedPermission)requestedPermission;

- (void)requestPermission:(PGRequestedPermission)requestedPermission withCompletionBlock:(void (^)(BOOL authorized, NSError *error))completionBlock;

+ (void)presentPermissionGetwayInViewController:(UIViewController *)viewController
                         forRequestedPermission:(PGRequestedPermission)requestedPermission
                            withCompletionBlock:(void (^)())completionBlock;

- (UIUserNotificationSettings *)notificationSettings;

- (void)reportNotificationRegisteredWithSettings:(UIUserNotificationSettings *)notificationSettings;

- (void)reportNotificationDeviceToken:(NSData *)deviceToken;

- (void)reportNotificationRegistrationError:(NSError *)error;

@end
