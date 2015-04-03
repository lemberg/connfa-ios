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

@end

@implementation DCDayEventsController

static NSString *ratingsImagesName[] = {@"", @"ic_experience_beginner", @"ic_experience_intermediate", @"ic_experience_advanced" };

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
//    NSIndexPath *actualCell = [self.eventsDataSource actualEventIndexPath];

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
        [weakSelf updateCell:cell atIndexPath:indexPath];
        
        return cell;
    }];
}

- (void)updateCell:(DCEventCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    DCEvent *event = [self.eventsDataSource eventForIndexPath:indexPath];
    NSInteger eventsCountInSection = [self.eventsDataSource tableView:nil numberOfRowsInSection:indexPath.section];
    cell.isLastCellInSection = ( indexPath.row == eventsCountInSection - 1)? YES : NO;
    NSString *eventTitle =  event.name;
    NSString *trackName = [(DCTrack*)[event.tracks anyObject] name];
    
    if (![self isEventHasAdditionalFields:event]) {
        [cell updateWithTitle:eventTitle andPlace:event.place];
    } else {
        [cell updateWithTitle:eventTitle
                     subTitle:trackName
                     speakers:[self speakersFromEvent:event]
                        place:event.place];
        
    }
   
    NSInteger eventRating = [event.level.levelId integerValue];
    NSString *ratingImageName = ratingsImagesName[eventRating];
    cell.eventLevelImageView.image = [UIImage imageNamed:ratingImageName];
    cell.eventImageView.image = event.imageForEvent;
    if (!indexPath.row) {

        cell.startTimeLabel.text = [self hourFormatForDate:event.startDate] ;
        cell.endTimeLabel.text  = [self hourFormatForDate:event.endDate];
    }
    cell.delegate = self;
}

- (NSString *)hourFormatForDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm aaa"];
    NSString *dateDisplay = [dateFormatter stringFromDate:date];
    return  dateDisplay;
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

- (BOOL)isEventHasAdditionalFields:(DCEvent *)event
{

//    BOOL isEnableAdditionalField = event.getTypeID == DC_EVENT_SPEACH;
    return [[self speakersFromEvent:event] length] > 0;
}

- (NSString *)speakersFromEvent:(DCEvent *)event
{
    NSMutableString *speakersList = [NSMutableString stringWithString:@""];
    for (DCSpeaker *speaker in [event.speakers allObjects]) {
        if (speakersList.length > 0) {
            [speakersList appendString:@", "];
        }
        
        [speakersList appendString:speaker.name];
    }
    return [NSString stringWithString:speakersList];
}

#pragma mark - UITableView delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DCEvent *event = [self.eventsDataSource eventForIndexPath:indexPath];
    return [self isEventHasAdditionalFields:event]? 110 : 75;
}

@end
