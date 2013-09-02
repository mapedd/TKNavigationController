//
//  TKNavigationViewController.h
//  ZWMobile
//
//  Created by Tomasz Kuźma on 5/27/13.
//  Copyright (c) 2013 creadhoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKNavigationController : UIViewController{
    UIView *_toolBar;
}

/* Default 44.0f */
@property (nonatomic, assign) CGFloat toolBarHeight;

- (id)initWithRootViewController:(UIViewController *)rootViewController
                navigatorToolBar:(UIView *)navigatorToolbar
            bottomViewController:(UIViewController *)viewController;

- (void)showToolbar:(BOOL)show
           animated:(BOOL)animated
         completion:(void(^)(void))completion;

- (void)showBottomViewController:(BOOL)show
                        animated:(BOOL)animated
                      completion:(void(^)(void))completion;

@property (nonatomic, strong) UIViewController *mainViewController;

@property (nonatomic, strong) UIViewController *bottomViewController;


@end

@interface UIViewController (TKNavigationController)

- (TKNavigationController *)TKNavigationController;

@end