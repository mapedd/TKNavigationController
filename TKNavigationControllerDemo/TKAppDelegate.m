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
    UINavigationController *topNav = [[UINavigationController alloc] initWithRootViewController:[[TKViewController alloc] init]];
    UINavigationController *bottomNav = [[UINavigationController alloc] initWithRootViewController:[[TKViewController alloc] init]];
    UILabel *toolBar = [[UILabel alloc] initWithFrame:CGRectZero];
    toolBar.text = NSLocalizedString(@"Checkout with 10 items",nil);
    toolBar.backgroundColor = [UIColor colorWithRed:0.220 green:0.922 blue:0.349 alpha:1.000];
    toolBar.font = [UIFont boldSystemFontOfSize:24.0f];
    toolBar.textAlignment = NSTextAlignmentCenter;
    self.viewController = [[TKNavigationController alloc] initWithRootViewController:topNav
                                                                    navigatorToolBar:toolBar
                                                                bottomViewController:bottomNav];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
