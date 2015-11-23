
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
