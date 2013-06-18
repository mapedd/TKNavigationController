//
//  TKNavigationViewController.m
//  ZWMobile
//
//  Created by Tomasz Kuźma on 5/27/13.
//  Copyright (c) 2013 creadhoc. All rights reserved.
//

#import "TKNavigationController.h"
#import "UIView+TKGeometry.h"
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



@property (nonatomic, strong) UIViewController *mainViewController;

@property (nonatomic, strong) UIViewController *bottomViewController;

@property (nonatomic, strong) UIView *toolBar;



- (UIView *)mainView;

- (UIView *)bottomView;

@end

@implementation TKNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nil bundle:nil];
    if(!self)return nil;
    _toolBarHeight = 44.0f;
    return self;
}

- (id)initWithRootViewController:(UIViewController *)mainViewController
                navigatorToolBar:(UIView *)navigatorToolbar
            bottomViewController:(UIViewController *)bottomViewController{
    
    NSParameterAssert(mainViewController);
    NSParameterAssert(navigatorToolbar);
    NSParameterAssert(bottomViewController);
    
    self = [self initWithNibName:nil bundle:nil];
    if (!self) return nil;
    
    self.mainViewController = mainViewController;
    self.toolBar = navigatorToolbar;
    self.bottomViewController = bottomViewController;
    
    [navigatorToolbar setUserInteractionEnabled:YES];
    [navigatorToolbar addGestureRecognizer:self.panGestureRecognizer];
    [navigatorToolbar addGestureRecognizer:self.tapGestureRecognizer];
    
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

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [UIView animateWithDuration:duration animations:^{
            self.bottomViewController.view.yOrigin = _navFlags.isBottomShown ? 0.0f : self.view.height - 44.0f;
    }];
}


#pragma mark - Actions

- (void)panWithLocation:(CGPoint)location animationBlock:(BOOL)animationBlock{

    
    CGFloat newYOrigin = self.bottomView.yOrigin;
    newYOrigin += location.y - prevLocation.y;
    
    if (newYOrigin < 0.0f) {
        newYOrigin = 0.0f;
    }
    else if (newYOrigin > self.view.height - self.toolBarHeight){
        newYOrigin = self.view.height - self.toolBarHeight;
    }
    
    self.bottomView.yOrigin = newYOrigin;
    CGFloat newAlpha = newYOrigin / self.view.height;

    self.toolBar.alpha = newAlpha;
    self.toolBar.yOrigin = newYOrigin;
}

- (void)panGesture:(UIPanGestureRecognizer *)panGesture{
    
    CGPoint currLocation = [panGesture locationInView:self.view];
    CGPoint velocity = [panGesture velocityInView:self.view];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            [self addBottomViewToHierarchy:YES];
            [self addChildViewController:self.bottomViewController];
            prevLocation = currLocation;
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [self panWithLocation:currLocation animationBlock:NO];
            prevLocation = currLocation;
            break;
        }
        case UIGestureRecognizerStateCancelled:{
            [self endPanningWithVelocity:velocity];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [self endPanningWithVelocity:velocity];
            break;
        }
        default:
            break;
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)tapGesture{
    
    switch (tapGesture.state) {
        case UIGestureRecognizerStateBegan:break;
        case UIGestureRecognizerStateChanged: break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self showBottomViewController:YES animated:YES completion:nil];
            break;
        default: break;
    }
}

- (void)bottomDidMoveToParent:(UIViewController *)controller{
    [self.bottomViewController didMoveToParentViewController:controller];
    if (controller) {
        [self.bottomView addGestureRecognizer: self.panGestureRecognizer];
    }else{
        [self.toolBar addGestureRecognizer:self.panGestureRecognizer];
    }
}

#pragma mark - Public

- (void)showBottomViewController:(BOOL)show
                        animated:(BOOL)animated
                      completion:(void(^)(void))completion{
    
    if (show) {
        
    [self addBottomViewToHierarchy:YES];
    [self addChildViewController:self.bottomViewController];
        
    [UIView animateWithDuration:animated ? kMaxAnimDuration : 0.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.bottomView.yOrigin = 0.0f;
                         self.toolBar.yOrigin = 0.0f;
                         self.toolBar.alpha = 0.0f;
                         _navFlags.isBottomBeingShown = YES;
                     }
                     completion:^(BOOL finished) {
                         [self.bottomViewController didMoveToParentViewController:self];
                         [self bottomDidMoveToParent:self];
                         _navFlags.isBottomBeingShown = NO;
                         _navFlags.isBottomShown = YES;
                         if (completion) completion();
                     }];
     
    }
    else{
        [self.bottomViewController willMoveToParentViewController:nil];
        CGFloat newYOrigin = self.view.height - 44.0f;
        [UIView animateWithDuration:animated ? kMaxAnimDuration : 0.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.bottomViewController.view.yOrigin = newYOrigin;
                             self.toolBar.yOrigin = newYOrigin;
                             self.toolBar.alpha = 1.0f;
                             _navFlags.isBottomBeingShown = YES;
                         }
                         completion:^(BOOL finished) {
                             
                             [self bottomDidMoveToParent:nil];
                             [self.bottomViewController removeFromParentViewController];
                             [self addBottomViewToHierarchy:NO];
                             
                             _navFlags.isBottomBeingShown = NO;
                             _navFlags.isBottomShown = NO;
                             if (completion) completion();
                         }];
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
                             self.mainView.height -= self.toolBarHeight;
                             self.toolBar.yOrigin -= self.toolBarHeight;
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
                             self.mainView.height += self.toolBarHeight;
                             self.toolBar.yOrigin += self.toolBarHeight;
                         }
                         completion:^(BOOL finished) {
                             _navFlags.isToolBarBeingShown = NO;
                             _navFlags.isToolBarShown = NO;
                             if(completion) completion();
                         }];
    }
}


#pragma mark - Private

- (void)goToShown:(BOOL)shown{
    if (shown) {
        [self panWithLocation:CGPointZero animationBlock:YES];
        self.toolBar.alpha = 0.0f;
        self.bottomView.yOrigin = 0.0f;
        self.toolBar.yOrigin = 0.0f;
    }
    else{
        self.bottomView.yOrigin = self.view.height - self.toolBarHeight;
        self.toolBar.yOrigin = self.view.height - self.toolBarHeight;
        self.toolBar.alpha = 1.0f;
    }
}

- (void)endPanningWithVelocity:(CGPoint)velocity{
    
    NSTimeInterval duration;
    BOOL isGoingUp = velocity.y < 0;
    
    UIView *view = self.bottomViewController.view;
    
    if (isGoingUp)
        duration = (view.yOrigin/view.height) * kMaxAnimDuration;
    else
        duration = (ABS(view.height-view.yOrigin)/view.height) * kMaxAnimDuration;
    
    NSTimeInterval veloDur = MAX(duration, 0.15);
    
    [UIView animateWithDuration:veloDur
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         _navFlags.isBottomBeingShown = YES;
                         [self goToShown:isGoingUp];
                     }
                     completion:^(BOOL finished) { 
                         _navFlags.isBottomBeingShown = NO;
                         if (!isGoingUp) {
                             _navFlags.isBottomShown = NO;
                             [self.bottomViewController willMoveToParentViewController:nil];
                             [self addBottomViewToHierarchy:NO];
                             [self bottomDidMoveToParent:nil];
                             [self.bottomViewController removeFromParentViewController];
                         }
                         else{
                             _navFlags.isBottomShown = YES;
                             [self bottomDidMoveToParent:self];
                             
                         }
                     }];
}

- (void)addBottomViewToHierarchy:(BOOL)add{
    if (add) {
        if (!self.bottomView.superview) {
            CGRect rect = self.view.bounds;
            rect.origin.y = self.toolBar.yOrigin;
            self.bottomView.frame = rect;
            self.bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.view insertSubview:self.bottomView belowSubview:self.toolBar];
        }
    }
    else{
        if(self.bottomView.superview)
            [self.bottomView removeFromSuperview];
    }
}

- (void)addToolBarToView{
    if (!self.toolBar.superview) {
        [self.view addSubview:self.toolBar];
    }
    CGRect rect = CGRectMake(0.0f, self.view.height, self.view.width, self.toolBarHeight);
    self.toolBar.frame = rect;
    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (UIView *)mainView{
    return self.mainViewController.view;
}

- (UIView *)bottomView{
    return self.bottomViewController.view;
}

-  (UIPanGestureRecognizer *)panGestureRecognizer{
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    }
    return _panGestureRecognizer;
}

-  (UITapGestureRecognizer *)tapGestureRecognizer{
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    }
    return _tapGestureRecognizer;
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
