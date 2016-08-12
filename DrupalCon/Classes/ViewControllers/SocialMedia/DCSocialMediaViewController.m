
#import "DCSocialMediaViewController.h"
#import "UIConstants.h"
#import "DCAppSettings.h"
#import "UIScrollView+EmptyDataSet.h"

@interface DCSocialMediaViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property(nonatomic) __block DCMainProxyState previousState;
@property (weak, nonatomic) IBOutlet UIView *placeholderView;

@end

@implementation DCSocialMediaViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setNeedsStatusBarAppearanceUpdate];
  [self arrangeNavigationBar];
  
  self.tableView.emptyDataSetSource = self;
  self.tableView.emptyDataSetDelegate = self;
  self.tableView.tableFooterView = [UIView new];
  
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerScreenLoadAtGA:[NSString stringWithFormat:@"%@", self.navigationItem.title]];
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
  DCAppSettings* settings =
  [[[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCAppSettings class]
                                         inMainQueue:YES] lastObject];
  NSString *searchQuery = settings.searchQuery;
  if (searchQuery.length > 0) {
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    self.dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:settings.searchQuery
                                                                      APIClient:client];
  }
}

#pragma mark - DZNEmptyDataSetSource

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
  return [UIImage imageNamed:@"no_details"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
  NSString *text = @"Currently there are no twits";
  NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:kFontOpenSansRegular size:21.0],
                               NSForegroundColorAttributeName: [UIColor colorWithRed:163.0/255.0 green:163.0/255.0 blue:163.0/255.0 alpha:1.0]};
  return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - DZNEmptyDataSetDelegate

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
  DCAppSettings* settings =
  [[[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCAppSettings class]
                                         inMainQueue:YES] lastObject];
  NSString *searchQuery = settings.searchQuery;
  return searchQuery.length == 0;
}

#pragma mark - Google Analytics

- (void)registerScreenLoadAtGA:(NSString*)message {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker
     set:kGAIScreenName
     value:[NSString stringWithFormat:@"%@ loaded, message: %@",
            NSStringFromClass(self.class), message]];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}


@end
