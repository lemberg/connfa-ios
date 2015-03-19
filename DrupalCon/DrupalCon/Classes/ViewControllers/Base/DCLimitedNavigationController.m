//
//  DCLimitedNavigationController.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 3/3/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCLimitedNavigationController.h"

#define MAX_DEPTH 2

CompletionBlock completion;


@interface DCLimitedNavigationController ()

@property (nonatomic) int backPressCount;

@end


@implementation DCLimitedNavigationController

- (instancetype) initWithRootViewController:(UIViewController *)rootViewController completion:(CompletionBlock)aBlock
{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
        completion = aBlock;
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

#pragma mark - UINavigationController delegate


- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![self.viewControllers containsObject:viewController])
        self.backPressCount = 0;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    self.backPressCount++;
    
    if ((self.backPressCount == MAX_DEPTH) || (self.viewControllers.count == 2))
    {
        [self dismissViewControllerAnimated:YES completion:nil];
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

@end
