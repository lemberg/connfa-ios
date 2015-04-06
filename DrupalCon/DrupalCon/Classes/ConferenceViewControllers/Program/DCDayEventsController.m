//
//  DCDayEventsController.m
//  DrupalCon
//
//  Created by Olexandr on 3/10/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCDayEventsController.h"
#import "DCEventCell.h"
#import "DCDayEventsDataSource.h"
#import "DCTimeRange+DC.h"
#import "DCTime+DC.h"
#import "DCType+DC.h"
#import "DCSpeaker+DC.h"
#import "DCLevel+DC.h"
#import "DCEventDetailViewController.h"
#import "DCLimitedNavigationController.h"
#import "DCAppFacade.h"
#import "DCTrack+DC.h"

@interface DCDayEventsController ()<DCEventCellProtocol>

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UILabel *noItemsLabel;

@property (nonatomic, strong) NSString* stubMessage;
@property (nonatomic) DCDayEventsDataSource *eventsDataSource;

@property (nonatomic, strong) DCEventCell* cellPrototype;

@end

@implementation DCDayEventsController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.stubMessage)
    {
        [self registerCells];
        [self initDataSource];
        
        self.cellPrototype = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DCEventCell class])];
    }
    else
    {
        self.tableView.dataSource = nil;
        self.tableView.hidden = YES;
        
        self.noItemsLabel.hidden = NO;
        self.noItemsLabel.text = self.stubMessage;
    }
}

- (void) dealloc
{
    self.stubMessage = nil;
    self.cellPrototype = nil;
}

- (void) initAsStubController:(NSString*)noEventMessage
{
    self.stubMessage = noEventMessage;
}

- (void)updateEvents
{
    [self.eventsDataSource reloadEvents];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)registerCells
{
    NSString *className = NSStringFromClass([DCEventCell class]);
    [self.tableView registerNib:[UINib nibWithNibName:className bundle:nil] forCellReuseIdentifier:className];
}

- (void)initDataSource
{
    self.eventsDataSource = [[DCDayEventsDataSource alloc] initWithTableView:self.tableView eventStrategy:self.eventsStrategy date:self.date];
    __weak typeof (self) weakSelf = self;
    [self.eventsDataSource setPrepareBlockForTableView:^UITableViewCell* (UITableView * tableView, NSIndexPath *indexPath) {
        NSString *cellIdentifier = NSStringFromClass([DCEventCell class]);
        DCEventCell *cell = (DCEventCell*)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        
        DCEvent *event = [weakSelf.eventsDataSource eventForIndexPath:indexPath];
        NSInteger eventsCountInSection = [weakSelf.eventsDataSource tableView:nil numberOfRowsInSection:indexPath.section];
        cell.isLastCellInSection = (indexPath.row == eventsCountInSection - 1)? YES : NO;
        cell.isFirstCellInSection = !indexPath.row;

        [cell initData:event delegate:weakSelf];
        return cell;
    }];
}

- (void)didSelectCell:(DCEventCell *)eventCell {
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:eventCell];
    DCEvent *selectedEvent = [self.eventsDataSource eventForIndexPath:cellIndexPath];
    [self openDetailScreenForEvent:selectedEvent];
}

- (void)openDetailScreenForEvent:(DCEvent *)event
{
    
    DCEventDetailViewController * detailController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    [detailController setCloseCallback:^(){
        if (self.eventsStrategy.strategy == EDCEeventStrategyFavorites) {
            [self updateEvents];
        }
    }];
    
    [detailController setEvent:event];
    
    DCLimitedNavigationController * navContainer = [[DCLimitedNavigationController alloc] initWithRootViewController:detailController completion:^{
        [self setNeedsStatusBarAppearanceUpdate];
        [self.tableView reloadData];
    }];
    
    [[DCAppFacade shared].mainNavigationController presentViewController: navContainer animated:YES completion:nil];
}

#pragma mark - UITableView delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DCEvent *event = [self.eventsDataSource eventForIndexPath:indexPath];
    [self.cellPrototype initData:event delegate:self];
  //  [self.cellPrototype layoutSubviews];
    
    return [self.cellPrototype getHeightForEvent:event isFirstInSection:!indexPath.row];
    
   // CGFloat height = /*[cellPrototype getHeightForEvent:event isFirstInSection:!indexPath.row];*/[self.cellPrototype.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
   // return height;
}

@end
