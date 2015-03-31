//
//  DCLimitedNavigationController.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 3/3/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCLimitedNavigationController.h"

#define DEFAULT_MAX_DEPTH 2

    // block that performs after NavigationController Dismisses
CompletionBlock completion;

    // block that performs when NavigationController should dismiss. If it isn't nil, developer is responsible for
    // hiding NavigationController. CompletionBlock won't be performed in this case
BackButtonBlock dismissAction;


@interface DCLimitedNavigationController ()

@property (nonatomic) int backPressCount;

@end


@implementation DCLimitedNavigationController

- (instancetype) initWithRootViewController:(UIViewController *)rootViewController completion:(CompletionBlock)aBlock depth:(NSInteger)maxDepth
{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
        completion = aBlock;
        dismissAction = nil;
        
        self.maxDepth = (maxDepth >= 2) ? maxDepth : DEFAULT_MAX_DEPTH;
    }
    return self;
}

- (instancetype) initWithRootViewController:(UIViewController *)rootViewController
                                 completion:(CompletionBlock)aBlock
{
    return [self initWithRootViewController:rootViewController completion:aBlock depth:-1];
}

- (instancetype) initWithRootViewController:(UIViewController *)rootViewController
                              dismissAction:(BackButtonBlock)aBlock
                                      depth:(NSInteger)maxDepth
{
    self = [self initWithRootViewController:rootViewController completion:nil depth:maxDepth];
    if (self)
    {
        dismissAction = aBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self arrangeNavigationBar];
    self.navigationBar.translucent = YES;
    
    self.backPressCount = 0;
    self.delegate = self;
    
    [self pushViewController:[UIViewController new] animated:NO];
}

- (void) arrangeNavigationBar
{
    [self.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    
    self.backPressCount = 0;
}

#pragma mark - UINavigationController delegate

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    self.backPressCount++;
    
    if ((self.backPressCount == self.maxDepth) || (self.viewControllers.count == 2))
    {
        if (dismissAction)
        {
                // custom dismiss action
            dismissAction();
        }
        else
        {
                // usual dismiss. In this case NavigationController mus te shown modally
            [self dismissViewControllerAnimated:YES completion:completion];
        }
        return NO;
    }
    else // just do as usual...
    {
            //  UINavigationController doesn't declare it's a delegate, so we
            //  have to do this ugliness…
        BOOL (*f)(id, SEL, ...) = [UINavigationController instanceMethodForSelector: _cmd];
        BOOL shouldPop = f(self, _cmd, navigationBar, item);
        return shouldPop;
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    // parent is nil if this view controller was removed
}

-(UIViewController *)childViewControllerForStatusBarStyle
{
    return self.visibleViewController;
}

@end
