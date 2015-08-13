//
//  PermissionGatewayViewController.h
//  PermissionGateway
//
//  Created by Brennan Stehling on 8/10/15.
//  Copyright (c) 2015 Brennan Stehling. All rights reserved.
//

@import Foundation;
@import UIKit;

#import "PGPermissionGateway.h"

typedef void(^PGViewControllerCompletionBlock)(BOOL granted, NSError *error);

@interface PGPermissionGatewayViewController : UIViewController

@property (nonatomic, copy) PGViewControllerCompletionBlock completionBlock;
@property (nonatomic, assign) PGRequestedPermission requestedPermission;

+ (void)presentPermissionGetwayInViewController:(UIViewController *)viewController
                         forRequestedPermission:(PGRequestedPermission)requestedPermission
                            withCompletionBlock:(void (^)(BOOL granted, NSError *error))completionBlock;

@end
