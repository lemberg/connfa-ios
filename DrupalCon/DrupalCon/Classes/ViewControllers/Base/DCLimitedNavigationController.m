/**********************************************************************************
 *                                                                           
 *  The MIT License (MIT)
 *  Copyright (c) 2015 Lemberg Solutions Limited
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the 
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *   The above copyright notice and this permission notice shall be included in
 *   all  copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM,  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 *  IN THE SOFTWARE.
 *
 *                                                                           
 *****************************************************************************/



#import "DCLimitedNavigationController.h"

#define DEFAULT_MAX_DEPTH 2

// block that performs after NavigationController Dismisses
CompletionBlock completion;

// block that performs when NavigationController should dismiss. If it isn't
// nil, developer is responsible for
// hiding NavigationController. CompletionBlock won't be performed in this case
BackButtonBlock dismissAction;

@interface DCLimitedNavigationController ()

@property(nonatomic) int backPressCount;
@property(nonatomic) BOOL shouldAnimateNavigationBar;

@end

@implementation DCLimitedNavigationController

- (instancetype)initWithRootViewController:(UIViewController*)rootViewController
                                completion:(CompletionBlock)aBlock
                                     depth:(NSInteger)maxDepth {
  self = [super initWithRootViewController:rootViewController];
  if (self) {
    completion = aBlock;
    dismissAction = nil;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.maxDepth = (maxDepth >= 2) ? maxDepth : DEFAULT_MAX_DEPTH;
  }
  return self;
}

- (instancetype)initWithRootViewController:(UIViewController*)rootViewController
                                completion:(CompletionBlock)aBlock {
  return [self initWithRootViewController:rootViewController
                               completion:aBlock
                                    depth:-1];
}

- (instancetype)initWithRootViewController:(UIViewController*)rootViewController
                             dismissAction:(BackButtonBlock)aBlock
                                     depth:(NSInteger)maxDepth {
  self = [self initWithRootViewController:rootViewController
                               completion:nil
                                    depth:maxDepth];
  if (self) {
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
  self.shouldAnimateNavigationBar = YES;

  [self pushViewController:[UIViewController new] animated:NO];
}

- (void)onBackButtonClick {
  [self popViewControllerAnimated:YES];
}

- (void)arrangeNavigationBar {
  [self.navigationBar setBackgroundImage:[UIImage new]
                           forBarMetrics:UIBarMetricsDefault];
  self.navigationBar.shadowImage = [UIImage new];
  self.navigationBar.translucent = YES;
}

- (void)pushViewController:(UIViewController*)viewController
                  animated:(BOOL)animated {
  [super pushViewController:viewController animated:animated];

  // disable swipe-to-Back gesture
  if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    self.interactivePopGestureRecognizer.enabled = NO;
  }

  self.backPressCount = 0;
}

- (BOOL)navigationBar:(UINavigationBar*)navigationBar
        shouldPopItem:(UINavigationItem*)item {
  [self popViewControllerAnimated:YES];
  return self.shouldAnimateNavigationBar;
}

- (UIViewController*)popViewControllerAnimated:(BOOL)animated {
  self.backPressCount++;

  if ((self.backPressCount == self.maxDepth) ||
      (self.viewControllers.count == 2)) {
    self.shouldAnimateNavigationBar = NO;
    if (dismissAction) {
      // custom dismiss action
      dismissAction();
    } else {
      // usual dismiss. In this case NavigationController mus te shown modally
      [self dismissViewControllerAnimated:YES completion:completion];
    }
    return nil;
  } else  // just do as usual...
  {
    return [super popViewControllerAnimated:animated];
  }
}

#pragma mark - UINavigationController delegate

- (UIViewController*)childViewControllerForStatusBarStyle {
  return self.visibleViewController;
}

@end
