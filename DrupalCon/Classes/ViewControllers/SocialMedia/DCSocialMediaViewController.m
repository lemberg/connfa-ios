
#import "DCSocialMediaViewController.h"
#import "UIConstants.h"

@interface DCSocialMediaViewController ()


@end

@implementation DCSocialMediaViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setNeedsStatusBarAppearanceUpdate];
  [self arrangeNavigationBar];
  TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
  self.dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:@"#drupalcon OR @lemberg_co_uk"
                                                                      APIClient:client];

}

#pragma mark - View appearance
- (void)arrangeNavigationBar {
  self.navigationController.navigationBar.barTintColor = [DCAppConfiguration navigationBarColor];
  NSDictionary* textAttributes = NAV_BAR_TITLE_ATTRIBUTES;
  
  self.navigationController.navigationBar.titleTextAttributes = textAttributes;
  self.navigationController.navigationBar.translucent = NO;
  
  [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
  
  self.navigationController.navigationBar.barTintColor =
  [DCAppConfiguration speakerDetailBarColor];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - Private


@end
