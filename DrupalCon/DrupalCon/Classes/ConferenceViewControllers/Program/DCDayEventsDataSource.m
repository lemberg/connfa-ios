//
//  DCDayEventsDataSource.m
//  DrupalCon
//
//  Created by Olexandr on 3/12/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCDayEventsDataSource.h"
#import "NSArray+DC.h"
#import "DCEventStrategy.h"
#import "DCTimeRange+DC.h"
#import "DCTime.h"
#import "NSDate+DC.h"
#import "DCEvent+DC.h"

@interface DCDayEventsDataSource()

@property (strong, nonatomic) DCEventStrategy          *eventStrategy;
@property (strong, nonatomic) NSDate                   *selectedDay;

@property (weak, nonatomic  ) UITableView              *tableView;


@property (strong, nonatomic)  NSArray          *eventsByTimeRange;

@property (strong, nonatomic) NSIndexPath       *actualEventIndexPath;
@end

@implementation DCDayEventsDataSource


- (instancetype)initWithTableView:(UITableView *)tableView
                    eventStrategy:(DCEventStrategy *)eventStrategy
                             date:(NSDate *)date
{
    self = [super init];
    if (self) {
        self.tableView            = tableView;
        self.tableView.dataSource = self;
        self.eventStrategy        = eventStrategy;
        self.selectedDay          = date;
        [self loadEvents];
    }
    return self;
    
}

- (void)loadEvents
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSArray *eventsByTimeRange = [self eventsSortedByTimeRange];
        [self updateActualEventIndexPathForTimeRange:eventsByTimeRange];
        dispatch_async(dispatch_get_main_queue(), ^{
//            
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            strongSelf.eventsByTimeRange = eventsByTimeRange;
            [strongSelf.tableView reloadData];
            [strongSelf.tableView scrollToRowAtIndexPath:strongSelf.actualEventIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    });
}

- (void)reloadEvents
{
    [self loadEvents];
}

static NSString * kDCTimeslotKEY = @"timeslot_key";
static NSString * kDCTimeslotEventKEY = @"timeslot_event_key";

- (NSArray *)eventsSortedByTimeRange
{
    NSMutableArray *uniqueTimeSlotsSource = [NSMutableArray array];
    
    NSArray *eventsForDay = [self eventsForDay];
    NSArray *uniqueTimeSlotForDay = [self.eventStrategy uniqueTimeRangesForDay:self.selectedDay];
    
    for (DCTimeRange * timerange in uniqueTimeSlotForDay) {
        NSArray *timeslotEvents = [[[eventsForDay eventsForTimeRange:timerange] sortedByKey:kDCEventIdKey] sortedByKey:kDCEventOrderKey];

        NSDictionary *timeslotDict = [[NSDictionary alloc] initWithObjects:@[timerange, timeslotEvents] forKeys:@[kDCTimeslotKEY, kDCTimeslotEventKEY]];
        [uniqueTimeSlotsSource addObject:timeslotDict];
    }
    
    return [NSArray arrayWithArray:uniqueTimeSlotsSource];
}

- (NSArray *)eventsForDay
{
    return [self.eventStrategy eventsForDay:self.selectedDay];
}


- (void)registerCellWithNibName:(NSString *)nibName
{
    NSString *className = nibName;//NSStringFromClass([DCEventCell class]);
    [self.tableView registerNib:[UINib nibWithNibName:className bundle:nil] forCellReuseIdentifier:className];
}

#pragma mark - TableViewDataSource implementation

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(self.prepareBlockForTableView);
    return self.prepareBlockForTableView(tableView, indexPath);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.eventsByTimeRange.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.eventsByTimeRange[section][kDCTimeslotEventKEY] count];
}


- (DCEvent *)eventForIndexPath:(NSIndexPath *)indexPath
{
    return self.eventsByTimeRange[indexPath.section][kDCTimeslotEventKEY][indexPath.row];
}

- (DCTimeRange *)timeRangeForSection:(NSInteger)section
{
    return self.eventsByTimeRange[section][kDCTimeslotKEY];
}

- (void)updateActualEventIndexPathForTimeRange:(NSArray *)array
{
    NSInteger currentHour = [self currentHour];
    NSInteger sectionNumber = 0;
    if (![NSDate dc_isDateInToday:self.selectedDay]) {
        return;
    }
    for (NSDictionary *sectionInfo in array) {
        
        DCTimeRange *timeRange = sectionInfo[kDCTimeslotKEY];
        
        if ([timeRange.from.hour integerValue] >= currentHour ) {
            self.actualEventIndexPath = [NSIndexPath indexPathForItem:0 inSection:sectionNumber];
            break;
        }
        
        sectionNumber++;
    }
}

- (NSIndexPath *)actualEventIndexPath
{
    return _actualEventIndexPath;
}


- (NSInteger)currentHour
{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    return hour;
}

@end
