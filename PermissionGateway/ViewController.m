//
//  ViewController.m
//  PermissionGateway
//
//  Created by Brennan Stehling on 8/10/15.
//  Copyright (c) 2015 Brennan Stehling. All rights reserved.
//

#import "ViewController.h"

#import "PGPermissionGateway.h"
#import "PGPermissionGatewayViewController.h"

#define kTagTitleLabel 1
#define kTagStatusView 2

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *permissions;

@end

@implementation ViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.permissions = @[
                         @{
                             @"title" : @"Photo Permission Title",
                             @"body" : @"Photo Permission Body",
                             @"permission" : @(PGRequestedPermissionPhoto) },
                         @{
                             @"title" : @"Camera Permission Title",
                             @"body" : @"Camera Permission Body",
                             @"permission" : @(PGRequestedPermissionCamera) },
                         @{
                             @"title" : @"Microphone Permission Title",
                             @"body" : @"Microphone Permission Body",
                             @"permission" : @(PGRequestedPermissionMicrophone) },
                         @{
                             @"title" : @"Notification Permission Title",
                             @"body" : @"Notification Permission Body",
                             @"permission" : @(PGRequestedPermissionNotification) },
                         @{
                             @"title" : @"Contacts Permission Title",
                             @"body" : @"Contacts Permission Body",
                             @"permission" : @(PGRequestedPermissionContacts) },
                         @{
                             @"title" : @"Location Permission Title",
                             @"body" : @"Location Permission Body",
                             @"permission" : @(PGRequestedPermissionLocation) }
                       ];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - Private
#pragma mark -

- (UIColor *)colorForPermissionStatus:(PGPermissionStatus)permissionStatus {
    UIColor *color = nil;
    
    switch (permissionStatus) {
        case PGPermissionStatusGatewayDenied:
            color = [UIColor yellowColor];
            break;
        case PGPermissionStatusAllowed:
            color = [UIColor greenColor];
            break;
        case PGPermissionStatusDenied:
            color = [UIColor redColor];
            break;
            
        default:
            color = [UIColor grayColor];
            break;
    }
    
    return color;
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.permissions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PermissionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *permission = self.permissions[indexPath.row];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kTagTitleLabel];
    UIView *statusView = [cell viewWithTag:kTagStatusView];
    
    PGRequestedPermission requestedPermission = (PGRequestedPermission)[permission[@"permission"] unsignedIntegerValue];
    PGPermissionStatus permissionStatus = [[PGPermissionGateway sharedInstance] statusForRequestedPermission:requestedPermission];
    UIColor *statusColor = [self colorForPermissionStatus:permissionStatus];
    
    NSString *title = NSLocalizedString(permission[@"title"], @"Permission Title");
    
    titleLabel.text = title;
    statusView.backgroundColor = statusColor;
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *permission = self.permissions[indexPath.row];
    PGRequestedPermission requestedPermission = (PGRequestedPermission)[permission[@"permission"] unsignedIntegerValue];
    
    [PGPermissionGatewayViewController presentPermissionGetwayInViewController:self forRequestedPermission:requestedPermission withCompletionBlock:^{
        DebugLog(@"Presented Permission Gateway");
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

@end
