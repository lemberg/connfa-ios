
#import "DCSocialMediaViewController.h"
#import "UIConstants.h"
#import "DCTwitter.h"

@interface DCSocialMediaViewController ()

@property(nonatomic) __block DCMainProxyState previousState;

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
  
  [[DCMainProxy sharedProxy]
   setDataReadyCallback:^(DCMainProxyState mainProxyState) {
     dispatch_async(dispatch_get_main_queue(), ^{
       NSLog(@"Data ready callback %d", mainProxyState);
       if (!self.previousState) {
         [self reloadData];
         self.previousState = mainProxyState;
       }
       
       if (mainProxyState == DCMainProxyStateDataUpdated) {
         [self reloadData];
       }
     });
   }];
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


- (void)reloadData {
    DCTwitter* twitter =
    [[[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCTwitter class]
                                           inMainQueue:YES] lastObject];
  
  NSLog(@"SearchQuery: %@", twitter.searchQuery);
  
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    self.dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:twitter.searchQuery //@"#drupalcon OR @lemberg_co_uk"
                                                                      APIClient:client];
}

@end
