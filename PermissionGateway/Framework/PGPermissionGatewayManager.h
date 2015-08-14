//
//  PermissionsGateway.h
//  PermissionGateway
//
//  Created by Brennan Stehling on 8/10/15.
//  Copyright (c) 2015 Brennan Stehling. All rights reserved.
//

@import Foundation;
@import UIKit;

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

// System Permission Status
typedef NS_ENUM(NSUInteger, PGSystemPermissionStatus) {
    PGSystemPermissionStatusUndefined = 0,
    PGSystemPermissionStatusAllowed = 1,
    PGSystemPermissionStatusDenied = 2
};

// Permission Status
typedef NS_ENUM(NSUInteger, PGPermissionStatus) {
    PGPermissionStatusNone = 0,
    PGPermissionStatusGatewayDenied = 1,
    PGPermissionStatusAllowed = 2,
    PGPermissionStatusDenied = 3
};

// Gateway Prompt Status
typedef NS_ENUM(NSUInteger, PGGatewayStatus) {
    PGGatewayStatusNone = 0,
    PGGatewayStatusAccepted = 1,
    PGGatewayStatusDeclined = 2
};

@interface PGPermissionGatewayManager : NSObject

+ (instancetype)sharedInstance;

- (PGPermissionStatus)statusForRequestedPermission:(PGRequestedPermission)requestedPermission;

- (void)requestPermission:(PGRequestedPermission)requestedPermission
      withCompletionBlock:(void (^)(BOOL authorized, NSError *error))completionBlock;

- (void)reportPermissionAllowedAtGateway:(PGRequestedPermission)requestedPermission;

- (void)reportPermissionDeniedAtGateway:(PGRequestedPermission)requestedPermission;

- (UIUserNotificationSettings *)notificationSettings;

- (void)reportNotificationRegisteredWithSettings:(UIUserNotificationSettings *)notificationSettings;

- (void)reportNotificationDeviceToken:(NSData *)deviceToken;

- (void)reportNotificationRegistrationError:(NSError *)error;

@end
