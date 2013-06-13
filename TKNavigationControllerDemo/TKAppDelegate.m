//
//  TKAppDelegate.m
//  TKNavigationControllerDemo
//
//  Created by Tomasz Kuźma on 6/11/13.
//  Copyright (c) 2013 mapedd. All rights reserved.
//

#import "TKAppDelegate.h"
#import "TKViewController.h"
#import "TKNavigationController.h"

@implementation TKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.viewController = [[TKNavigationController alloc] initWithRootViewController:[self topViewController]
                                                                    navigatorToolBar:[self toolBar]
                                                                bottomViewController:[self bottomViewController]];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (UIViewController *)bottomViewController{
    UIViewController *vc = [[TKViewController alloc] init];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",nil)
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(hideBottom:)];
    vc.navigationItem.leftBarButtonItem = backButton;
    UINavigationController *bottomNav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    return bottomNav;
}

- (UIViewController *)topViewController{
    UINavigationController *topNav = [[UINavigationController alloc] initWithRootViewController:[[TKViewController alloc] init]];
    return topNav;
}

- (UIView *)toolBar{
    UILabel *toolBar = [[UILabel alloc] initWithFrame:CGRectZero];
    toolBar.text = NSLocalizedString(@"Checkout with 10 items",nil);
    toolBar.backgroundColor = [UIColor colorWithRed:0.220 green:0.922 blue:0.349 alpha:1.000];
    toolBar.font = [UIFont boldSystemFontOfSize:24.0f];
    toolBar.textAlignment = NSTextAlignmentCenter;
    return toolBar;
}

- (void)hideBottom:(id)sender{
    [self.viewController.TKNavigationController showBottomViewController:NO animated:YES completion:nil];
}


@end
