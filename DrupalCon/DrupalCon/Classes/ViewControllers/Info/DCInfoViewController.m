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
#import "DCInfo.h"
#import "DCInfoCategory.h"
#import "DCAboutViewController.h"

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
    
    DCInfo* info = [[[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCInfo class] inMainQueue:YES] lastObject];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    self.items = [[info.infoCategory allObjects] sortedArrayUsingDescriptors:@[descriptor]];
    
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
    self.navigationItem.title = nil;

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
    
    cell.titleLabel.text = [(DCInfoCategory*)self.items[indexPath.row] name];
    BOOL isLastCell = (indexPath.row == self.items.count-1);
    cell.separator.hidden = isLastCell;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DCAboutViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
    [controller setData: self.items[indexPath.row]];
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
