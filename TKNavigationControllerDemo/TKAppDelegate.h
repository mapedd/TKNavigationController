//
//  TKAppDelegate.h
//  TKNavigationControllerDemo
//
//  Created by Tomasz Kuźma on 6/11/13.
//  Copyright (c) 2013 mapedd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKViewController;

@interface TKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TKViewController *viewController;

@end
