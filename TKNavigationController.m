//
//  TKNavigationViewController.m
//  ZWMobile
//
//  Created by Tomasz Kuźma on 5/27/13.
//  Copyright (c) 2013 creadhoc. All rights reserved.
//

#import "TKNavigationController.h"
#import <QuartzCore/QuartzCore.h>

const NSTimeInterval kMaxAnimDuration = 0.33;

@interface TKNavigationController (){
    CGPoint prevLocation;
    struct{
        unsigned int isBottomShown:1;
        unsigned int isBottomBeingShown:1;
        unsigned int isToolBarShown:1;
        unsigned int isToolBarBeingShown:1;
    }_navFlags;
}


@property (nonatomic,strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic,strong) UITapGestureRecognizer *tapGestureRecognizer;


@property (nonatomic, strong) UIView *toolBar;

@property (nonatomic, assign) NSInteger systemVersion;



- (UIView *)mainView;

- (UIView *)bottomView;

@end

@implementation TKNavigationController

#ifdef __IPHONE_7_0
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
#endif

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nil bundle:nil];
    if(!self)return nil;
    _toolBarHeight = 44.0f;
    self.systemVersion = [[[UIDevice currentDevice] systemVersion] integerValue];
    return self;
}

- (id)initWithRootViewController:(UIViewController *)mainViewController
                navigatorToolBar:(UIView *)navigatorToolbar
            bottomViewController:(UIViewController *)bottomViewController{
    
    NSParameterAssert(mainViewController);
    
    self = [self initWithNibName:nil bundle:nil];
    if (!self) return nil;
    
    self.mainViewController = mainViewController;
    self.toolBar = navigatorToolbar;
    self.bottomViewController = bottomViewController;
    
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self addChildViewController:self.mainViewController];
    self.mainView.frame = self.view.bounds;
    self.mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mainView];
    [self.mainViewController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self showToolbar:YES animated:NO completion:^{
    }];
}

#pragma mark - Public

- (void)showBottomViewController:(BOOL)show
                        animated:(BOOL)animated
                      completion:(void(^)(void))completion{
    
    if (show) {
        [self.mainViewController presentViewController:self.bottomViewController animated:animated completion:completion];
    }else{
        [self.mainViewController dismissViewControllerAnimated:animated completion:completion];
    }
}

- (void)showToolbar:(BOOL)show
           animated:(BOOL)animated
         completion:(void(^)(void))completion{
    if (show && !_navFlags.isToolBarShown && !_navFlags.isToolBarBeingShown) {
        _navFlags.isToolBarBeingShown = YES;
        
        [self addToolBarToView];
        
        [UIView animateWithDuration:animated ? kMaxAnimDuration : 0.0
                         animations:^{
                             CGRect frame = self.toolBar.frame;
                             frame.origin.y -= self.toolBarHeight;
                             self.toolBar.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             _navFlags.isToolBarBeingShown = NO;
                             _navFlags.isToolBarShown = YES;
                             if(completion) completion();
                         }];
    }
    else if (!show && _navFlags.isToolBarShown && !_navFlags.isToolBarBeingShown){
        _navFlags.isToolBarBeingShown = YES;
        
        [UIView animateWithDuration:animated ? kMaxAnimDuration : 0.0
                         animations:^{
                             CGRect frame = self.toolBar.frame;
                             frame.origin.y += self.toolBarHeight;
                             self.toolBar.frame =frame;
                         }
                         completion:^(BOOL finished) {
                             _navFlags.isToolBarBeingShown = NO;
                             _navFlags.isToolBarShown = NO;
                             if(completion) completion();
                         }];
    }
}


#pragma mark - Private



- (void)addToolBarToView{
    if (!self.toolBar.superview) {
        [self.view addSubview:self.toolBar];
        [self addShadowToToolBar];
    }
    CGRect rect = CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, self.toolBarHeight);
    self.toolBar.frame = rect;
    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}


- (void)addShadowToToolBar{
    CALayer *layer = self.toolBar.layer;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowRadius = 5.0f;
    layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    layer.shadowOpacity = 0.7f;
//    [layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.toolBar.bounds] CGPath]];
    [layer setMasksToBounds:NO];
}


- (UIView *)mainView{
    return self.mainViewController.view;
}

- (UIView *)bottomView{
    return self.bottomViewController.view;
}


@end

@implementation UIViewController (TKNavigationController)

- (TKNavigationController *)TKNavigationController{
    if ([self isKindOfClass:[TKNavigationController class]]) {
        return (TKNavigationController *)self;
    }
    else if([self.parentViewController isKindOfClass:[TKNavigationController class]]){
        return (TKNavigationController *)self.parentViewController;
    }
    else if([self.parentViewController isKindOfClass:[UINavigationController class]] &&
            [self.parentViewController.parentViewController isKindOfClass:[TKNavigationController class]]){
        return (TKNavigationController *)[self.parentViewController parentViewController];
    }
    else{
        return nil;
    }
}

@end
