//
//  HPAuthorizationViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPAuthorizationViewController.h"
//#import "HPBaseNetworkManager.h"
#import "NotificationsConstants.h"

#import "HPRootViewController.h"
#import "HPAppDelegate.h"
#import "HPBaseNetworkManager+AuthorizationAndRegistration.h"

@interface HPAuthorizationViewController ()

@end

@implementation HPAuthorizationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
    [self registerNotification];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - notifications

- (void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAuthResults:) name:kNeedUpdateAuthView object:nil];
}


- (void) unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdateAuthView object:nil];
}

- (IBAction)authBtnTap:(id)sender {
    if ((self.loginTextField.text.length > 0) && (self.pwdTextField.text.length > 0)) {
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys: self.loginTextField.text, @"email", self.pwdTextField.text, @"password", nil];
        [[HPBaseNetworkManager sharedNetworkManager] makeAutorizationRequest:params];
    } else {
        NSLog(@"Error: fill all fields");
    }
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - auth handler

- (void) handleAuthResults :(NSNotification *)notification {
    NSNumber *status =  [notification.userInfo objectForKey:@"status"];
    if ([status isEqualToNumber:@1]) {
        
        HPRootViewController *rootController;
        UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Storyboard_568" bundle:nil];
        rootController = [mainstoryboard instantiateViewControllerWithIdentifier:@"HPRootViewController"];
        ((HPAppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController = [[UINavigationController alloc] initWithRootViewController:rootController];
        } else {
        NSLog(@"Error: Auth Error");
    }
}



@end
