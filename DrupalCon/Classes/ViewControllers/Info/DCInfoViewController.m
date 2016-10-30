
#import "DCInfoViewController.h"
#import "DCInfoMenuCell.h"
#import "UIConstants.h"
#import "UIImage+Extension.h"
#import "DCInfo.h"
#import "DCInfoCategory.h"
#import "DCAboutViewController.h"
#import "DCLimitedNavigationController.h"

#define infoMenuItemCellId @"InfoMenuItemCellId"

@interface DCInfoViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) IBOutlet UITableView* tableView;
@property(nonatomic, strong) NSArray* items;
@property(nonatomic) __block DCMainProxyState previousState;
@property (weak, nonatomic) IBOutlet UIView *noDataView;

@end

@implementation DCInfoViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
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

- (void)reloadData {
  DCInfo* info =
      [[[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCInfo class]
                                             inMainQueue:YES] lastObject];

  NSSortDescriptor* orderDescriptor =
      [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];

  self.items = [[info.infoCategory allObjects]
      sortedArrayUsingDescriptors:@[orderDescriptor]];

  [self.tableView reloadData];
  self.noDataView.hidden = self.items.count > 0;
  self.tableView.hidden = !(self.items.count > 0);
}

#pragma mark - UITableView delegate and source

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section {
  return self.items.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  DCInfoMenuCell* cell =
      [tableView dequeueReusableCellWithIdentifier:infoMenuItemCellId];

  cell.titleLabel.text = [(DCInfoCategory*)self.items[indexPath.row] name];
  BOOL isLastCell = (indexPath.row == self.items.count - 1);
  cell.separator.hidden = isLastCell;

  return cell;
}

- (void)tableView:(UITableView*)tableView
    didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  DCAboutViewController* controller = [self.storyboard
      instantiateViewControllerWithIdentifier:@"AboutViewController"];
  [controller setData:self.items[indexPath.row]];

  DCLimitedNavigationController* navContainer =
      [[DCLimitedNavigationController alloc]
          initWithRootViewController:controller
                          completion:^{
                            [self setNeedsStatusBarAppearanceUpdate];
                          }];

  [self.navigationController presentViewController:navContainer
                                          animated:YES
                                        completion:nil];
}

@end
