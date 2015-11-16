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
- (void)reloadData {
  DCInfo* info =
      [[[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCInfo class]
                                             inMainQueue:YES] lastObject];

  NSSortDescriptor* orderDescriptor =
      [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
  NSSortDescriptor* iDDescriptor =
      [[NSSortDescriptor alloc] initWithKey:@"infoId" ascending:YES];

  self.items = [[info.infoCategory allObjects]
      sortedArrayUsingDescriptors:@[ orderDescriptor, iDDescriptor ]];

  [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self arrangeNavigationBar];
}

- (void)arrangeNavigationBar {
  self.navigationController.navigationBar.tintColor =
      [DCAppConfiguration navigationBarColor];
  ;
  self.navigationItem.title = nil;

  [self.navigationController.navigationBar
      setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]]
           forBarMetrics:UIBarMetricsDefault];
  self.navigationController.navigationBar.shadowImage = [UIImage new];
  self.navigationController.navigationBar.translucent = YES;
  self.navigationController.navigationBar.backgroundColor =
      [UIColor clearColor];
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
