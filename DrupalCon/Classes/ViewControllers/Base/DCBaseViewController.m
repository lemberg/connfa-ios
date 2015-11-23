
#import "DCBaseViewController.h"
#import "UIConstants.h"

@interface DCBaseViewController ()
@end

@implementation DCBaseViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self setNeedsStatusBarAppearanceUpdate];
  [self arrangeNavigationBar];
}

- (void)arrangeNavigationBar {
  if (self.navigatorBarStyle == EBaseViewControllerNatigatorBarStyleNormal) {
    self.navigationController.navigationBar.barTintColor =
        [DCAppConfiguration navigationBarColor];
    NSDictionary* textAttributes = NAV_BAR_TITLE_ATTRIBUTES;

    self.navigationController.navigationBar.titleTextAttributes =
        textAttributes;
    self.navigationController.navigationBar.translucent = NO;

    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
  } else if (self.navigatorBarStyle ==
             EBaseViewControllerNatigatorBarStyleTransparrent) {
    [self.navigationController.navigationBar setTitleTextAttributes:@{
      NSForegroundColorAttributeName : [UIColor whiteColor]
    }];
    [self.navigationController.navigationBar
        setBackgroundImage:[UIImage new]
             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
  }

  // hide annoying 1 px stripe between NavigationBar and controller View
  UIImageView* stripeUnderNavigationBar =
      [self findHairlineImageViewUnder:self.navigationController.navigationBar];
  stripeUnderNavigationBar.hidden = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleDefault;
}

- (UIImageView*)findHairlineImageViewUnder:(UIView*)view {
  if ([view isKindOfClass:UIImageView.class] &&
      view.bounds.size.height <= 1.0) {
    return (UIImageView*)view;
  }
  for (UIView* subview in view.subviews) {
    UIImageView* imageView = [self findHairlineImageViewUnder:subview];
    if (imageView) {
      return imageView;
    }
  }
  return nil;
}

- (void)registerScreenLoadAtGA:(NSString*)message {
  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker
        set:kGAIScreenName
      value:[NSString stringWithFormat:@"%@ loaded, message: %@",
                                       NSStringFromClass(self.class), message]];
  [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

@end
