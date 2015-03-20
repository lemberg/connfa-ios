//
//  DCInfoViewController.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 3/19/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCInfoViewController.h"
#import "DCInfoMenuCell.h"
#import "UIConstants.h"
#import "UIImage+Extension.h"

typedef NS_ENUM (int, DCInfoMenuSection) {
    DC_INFO_MENU_ABOUT_DRUPAL = 0,
    DC_INFO_MENU_TERMS,
    DC_INFO_MENU_PROGRAM,
    DC_INFO_MENU_ABOUT_APP
};

#define kInfoMenuItemTitle @"InfoMenuItemTitle"
#define kInfoMenuItemControllerId @"InfoMenuItemControllerId"

#define infoMenuItemCellId @"InfoMenuItemCellId"


@interface DCInfoViewController()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray* items;

@end



@implementation DCInfoViewController

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.items = @[
                   @{ kInfoMenuItemTitle: @"About DrupalCon",
                      kInfoMenuItemControllerId: @"AboutViewController" },
                   @{ kInfoMenuItemTitle: @"Terms and conditions",
                      kInfoMenuItemControllerId: @"AboutViewController" },
                   @{ kInfoMenuItemTitle: @"Program",
                      kInfoMenuItemControllerId: @"AboutViewController" },
                   @{ kInfoMenuItemTitle: @"About this app",
                      kInfoMenuItemControllerId: @"AboutViewController" }
                   ];
    
    [self.tableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self arrangeNavigationBar];
}

- (void) arrangeNavigationBar
{    
    self.navigationController.navigationBar.tintColor = NAV_BAR_COLOR;
    
    [self.navigationController.navigationBar setBackgroundImage: [UIImage imageWithColor:[UIColor clearColor]]
                                                  forBarMetrics: UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

#pragma mark - UITableView delegate and source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DCInfoMenuCell* cell = [tableView dequeueReusableCellWithIdentifier:infoMenuItemCellId];
    
    cell.titleLabel.text = self.items[indexPath.row] [kInfoMenuItemTitle];
    BOOL isLastCell = (indexPath.row == self.items.count-1);
    cell.separator.hidden = isLastCell;
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame: cell.bounds];
    cell.selectedBackgroundView.backgroundColor = MENU_SELECTION_COLOR;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self showViewControllerAssociatedWithMenuItem: (DCInfoMenuSection)indexPath.row];
}

- (void) showViewControllerAssociatedWithMenuItem:(DCInfoMenuSection)menuItem
{
    NSString *storyboardControllerID = self.items[menuItem][kInfoMenuItemControllerId];
    NSAssert(storyboardControllerID.length, @"No Storyboard ID for Menu item view controller");
    
    DCBaseViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:storyboardControllerID];
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
