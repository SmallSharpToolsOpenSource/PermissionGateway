//
//  PermissionsGateway.m
//  PermissionGateway
//
//  Created by Brennan Stehling on 8/10/15.
//  Copyright (c) 2015 Brennan Stehling. All rights reserved.
//

#import "PGPermissionGateway.h"

NSString * const PromptStatusPrefix = @"PromptStatus_";
NSString * const PromptStatusAccepted = @"Accepted";
NSString * const PromptStatusDeclined = @"Declined";

NSString * const NotificationDeviceTokenKey = @"NotificationDeviceToken";

@import AddressBook;
@import AssetsLibrary;
@import AVFoundation;
@import CoreLocation;
@import UIKit;

typedef void(^PGCompletionBlock)(BOOL granted, NSError *error);

#pragma mark - Class Extension
#pragma mark -

@interface PGPermissionGateway () <CLLocationManagerDelegate>

@property (nonatomic, copy) PGCompletionBlock completionBlock;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation PGPermissionGateway

#pragma mark - Public Methods
#pragma mark -

+ (instancetype)sharedInstance {
    static PGPermissionGateway *_instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instance = [[PGPermissionGateway alloc] init];
    });
    
    return _instance;
}

- (PGPermissionStatus)statusForRequestedPermission:(PGRequestedPermission)requestedPermission {
#if TARGET_IPHONE_SIMULATOR
#ifndef NDEBUG
    NSLog(@"Simulator is not fully supported");
#endif
    
    // return allowed for iOS Simulator if the user allowed the gateway prompt
    if (requestedPermission == PGRequestedPermissionNotification) {
        PGGatewayPromptStatus promptStatus = [self promptStatusForPermission:requestedPermission];
        
        if (promptStatus == PGGatewayPromptStatusAccepted) {
            return PGPermissionStatusAllowed;
        }
    }
#endif
    
    BOOL isSystemAuthorized = [self isSystemAuthorizedForPermission:requestedPermission];
    
    if (isSystemAuthorized) {
        return PGPermissionStatusAllowed;
    }
    
    PGGatewayPromptStatus promptStatus = [self promptStatusForPermission:requestedPermission];
    
    if (promptStatus == PGGatewayPromptStatusNone) {
        // not prompted by app yet
        return PGPermissionStatusNone;
    }
    else if (promptStatus == PGGatewayPromptStatusDeclined) {
        // app prompt was denied though system prompt may not have been presented
        return PGPermissionStatusGatewayDenied;
    }
    else if (promptStatus == PGGatewayPromptStatusAccepted) {
        // fall back on system authorization
        return isSystemAuthorized ? PGPermissionStatusAllowed : PGPermissionStatusDenied;
    }
    
    return PGPermissionStatusNone;
}

- (void)requestPermission:(PGRequestedPermission)requestedPermission
      withCompletionBlock:(void (^)(BOOL authorized, NSError *error))completionBlock {
    if (requestedPermission == PGRequestedPermissionPhoto) {
        [self requestPhotosAuthorizationWithCompletionBlock:completionBlock];
    }
    else if (requestedPermission == PGRequestedPermissionCamera) {
        [self requestCameraAuthorizationWithCompletionBlock:completionBlock];
    }
    else if (requestedPermission == PGRequestedPermissionMicrophone) {
        [self requestMicrophoneAuthorizationWithCompletionBlock:completionBlock];
    }
    else if (requestedPermission == PGRequestedPermissionNotification) {
        [self requestNotificationAuthorizationWithCompletionBlock:completionBlock];
    }
    else if (requestedPermission == PGRequestedPermissionContacts) {
        [self requestContactsAuthorizationWithCompletionBlock:completionBlock];
    }
    else if (requestedPermission == PGRequestedPermissionLocation) {
        [self requestLocationAuthorizationWithCompletionBlock:completionBlock];
    }
}

- (void)reportPermissionAllowedAtGateway:(PGRequestedPermission)requestedPermission {
    [self setPromptStatus:PGGatewayPromptStatusAccepted forRequestedPermission:requestedPermission];
}

- (void)reportPermissionDeniedAtGateway:(PGRequestedPermission)requestedPermission {
    [self setPromptStatus:PGGatewayPromptStatusDeclined forRequestedPermission:requestedPermission];
}

- (UIUserNotificationSettings *)notificationSettings {
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
    
    return settings;
}

- (void)reportNotificationRegisteredWithSettings:(UIUserNotificationSettings *)notificationSettings {
    // do nothing
}

- (void)reportNotificationDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenString = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenString forKey:NotificationDeviceTokenKey];
    
#ifndef NDEBUG
    NSLog(@"device token: %@", deviceTokenString);
#endif
    if (self.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(YES, nil);
            self.completionBlock = nil;
        });
    }
}

- (void)reportNotificationRegistrationError:(NSError *)error {
    if (self.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(NO, error);
            self.completionBlock = nil;
        });
    }
}

#pragma mark - Private Methods
#pragma mark -

- (void)promptForRequestedPermission:(PGRequestedPermission)requestedPermission
                 withCompletionBlock:(void (^)(PGPermissionStatus status, NSError *error))completionBlock {
    if (!completionBlock) {
        NSAssert(NO, @"Completion block is required.");
        return;
    }
    
    switch (requestedPermission) {
        case PGRequestedPermissionPhoto:
            break;
        case PGRequestedPermissionCamera:
            break;
        case PGRequestedPermissionMicrophone:
            break;
        case PGRequestedPermissionNotification:
            break;
        case PGRequestedPermissionContacts:
            break;
        case PGRequestedPermissionLocation:
            NSAssert(NO, @"Location permission is not supported");
            break;
            
        default:
            NSAssert(NO, @"Permission is not supported");
            break;
    }
    
    NSError *error = nil;
    
    if (completionBlock) {
        completionBlock(PGPermissionStatusNone, error);
    }
}

- (NSString *)keyForPromptStatusForPermission:(PGRequestedPermission)requestedPermission {
    NSString *key = @"";
    
    switch (requestedPermission) {
        case PGRequestedPermissionPhoto:
            key = [NSString stringWithFormat:@"%@%@", PromptStatusPrefix, @"Photo"];
            break;
        case PGRequestedPermissionCamera:
            key = [NSString stringWithFormat:@"%@%@", PromptStatusPrefix, @"Camera"];
            break;
        case PGRequestedPermissionMicrophone:
            key = [NSString stringWithFormat:@"%@%@", PromptStatusPrefix, @"Microphone"];
            break;
        case PGRequestedPermissionNotification:
            key = [NSString stringWithFormat:@"%@%@", PromptStatusPrefix, @"Notification"];
            break;
        case PGRequestedPermissionContacts:
            key = [NSString stringWithFormat:@"%@%@", PromptStatusPrefix, @"Contacts"];
            break;
        case PGRequestedPermissionLocation:
            key = [NSString stringWithFormat:@"%@%@", PromptStatusPrefix, @"Location"];
            break;
            
        default:
            NSAssert(NO, @"Permission is not supported");
            break;
    }
    
    return key;
}

- (PGGatewayPromptStatus)promptStatusForPermission:(PGRequestedPermission)requestedPermission {
    PGGatewayPromptStatus status = PGGatewayPromptStatusNone;
    
    NSString *key = [self keyForPromptStatusForPermission:requestedPermission];
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    
    if ([PromptStatusAccepted isEqualToString:value]) {
        status = PGGatewayPromptStatusAccepted;
    }
    else if ([PromptStatusDeclined isEqualToString:value]) {
        status = PGGatewayPromptStatusDeclined;
    }
    else {
        // leave as default
    }
    
    return status;
}

- (BOOL)isSystemAuthorizedForPermission:(PGRequestedPermission)requestedPermission {
    BOOL isAuthorized = NO;
    
    switch (requestedPermission) {
        case PGRequestedPermissionPhoto:
            isAuthorized = [self isPhotoPermissionAuthorized];
            break;
        case PGRequestedPermissionCamera:
            isAuthorized = [self isCameraPermissionAuthorized];
            break;
        case PGRequestedPermissionMicrophone:
            isAuthorized = [self isMicrophonePermissionAuthorized];
            break;
        case PGRequestedPermissionNotification:
            isAuthorized = [self isNotificationPermissionAuthorized];
            break;
        case PGRequestedPermissionContacts:
            isAuthorized = [self isContactsPermissionAuthorized];
            break;
        case PGRequestedPermissionLocation:
            isAuthorized = [self isLocationPermissionAuthorized];
            break;
            
        default:
            NSAssert(NO, @"Permission is not supported");
            break;
    }
    
    return isAuthorized;
}

- (void)setPromptStatus:(PGGatewayPromptStatus)promptStatus forRequestedPermission:(PGRequestedPermission)requestedPermission {
    NSString *key = [self keyForPromptStatusForPermission:requestedPermission];
    NSString *value = @"";
    
    switch (promptStatus) {
        case PGGatewayPromptStatusAccepted:
            value = PromptStatusAccepted;
            break;
        case PGGatewayPromptStatusDeclined:
            value = PromptStatusDeclined;
            break;
            
        default:
            // leave as default
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - System Permission Status
#pragma mark -

- (BOOL)isPhotoPermissionAuthorized {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    return status == ALAuthorizationStatusAuthorized;
}

- (BOOL)isCameraPermissionAuthorized {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return status == AVAuthorizationStatusAuthorized;
}

- (BOOL)isMicrophonePermissionAuthorized {
#if TARGET_IPHONE_SIMULATOR
#ifndef NDEBUG
    NSLog(@"Simulator is not fully supported");
#endif
    return NO;
#else
    AVAudioSessionRecordPermission permission = [[AVAudioSession sharedInstance] recordPermission];
    return permission == AVAudioSessionRecordPermissionGranted;
#endif
}

- (BOOL)isNotificationPermissionAuthorized {
    BOOL isRegistered = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    return isRegistered;
}

- (BOOL)isContactsPermissionAuthorized {
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    return status == kABAuthorizationStatusAuthorized;
}

- (BOOL)isLocationPermissionAuthorized {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse;
}

#pragma mark - Requesting Authorization
#pragma mark -

- (void)requestPhotosAuthorizationWithCompletionBlock:(void (^)(BOOL authorized, NSError *error))completionBlock {
    if (!completionBlock) {
        NSParameterAssert(completionBlock != NULL);
        return;
    }
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(YES, nil);
        });
    } failureBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, error);
        });
    }];
}

- (void)requestCameraAuthorizationWithCompletionBlock:(void (^)(BOOL authorized, NSError *error))completionBlock {
    if (!completionBlock) {
        NSParameterAssert(completionBlock != NULL);
        return;
    }
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(granted, nil);
        });
    }];
}

- (void)requestMicrophoneAuthorizationWithCompletionBlock:(void (^)(BOOL authorized, NSError *error))completionBlock {
#if TARGET_IPHONE_SIMULATOR
#ifndef NDEBUG
    NSLog(@"Simulator is not fully supported");
#endif
    if (completionBlock) {
        NSAssert([NSThread isMainThread], @"Must be main thread");
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, nil);
        });
    }
#else
    if (!completionBlock) {
        NSParameterAssert(completionBlock != NULL);
        return;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(granted, nil);
        });
    }];
#endif
}

- (void)requestNotificationAuthorizationWithCompletionBlock:(void (^)(BOOL authorized, NSError *error))completionBlock {
    if (!completionBlock) {
        NSParameterAssert(completionBlock != NULL);
        return;
    }
    
#if TARGET_IPHONE_SIMULATOR
#ifndef NDEBUG
    NSLog(@"Simulator is not fully supported");
#endif
    if (completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(YES, nil);
        });
    }
#else
    self.completionBlock = completionBlock;
    
    UIUserNotificationSettings *settings = [self notificationSettings];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

- (void)requestContactsAuthorizationWithCompletionBlock:(void (^)(BOOL authorized, NSError *error))completionBlock {
    if (!completionBlock) {
        NSParameterAssert(completionBlock != NULL);
        return;
    }
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(NO, (__bridge NSError *)error);
            });
        }
        else if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(YES, nil);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(NO, nil);
            });
        }
    });
}

- (void)requestLocationAuthorizationWithCompletionBlock:(void (^)(BOOL authorized, NSError *error))completionBlock {
    if (!completionBlock) {
        NSParameterAssert(completionBlock != NULL);
        return;
    }
    
    BOOL useAlways = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] !=  nil;
    BOOL useWhenInUse = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
    
    NSAssert(useAlways || useWhenInUse, @"Info.plist must include a key for NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription");
    
    self.completionBlock = completionBlock;
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    if (useAlways) {
        [locationManager requestAlwaysAuthorization];
    }
    else if (useWhenInUse) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    self.locationManager = locationManager;
}

#pragma mark - CLLocationManagerDelegate
#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusNotDetermined) {
        BOOL granted = status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse;
        if (self.completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionBlock(granted, nil);
                self.locationManager = nil;
            });
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(NO, error);
            self.completionBlock = nil;
            self.locationManager = nil;
        });
    }
}

@end
