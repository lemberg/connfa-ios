//
//  DCDayEventsDataSource.m
//  DrupalCon
//
//  Created by Olexandr on 3/12/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCDayEventsDataSource.h"


@interface DCDayEventsDataSource()

@end

@implementation DCDayEventsDataSource

- (void)loadEvents
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSArray *uniqueTimeSlotForDay = [self.eventStrategy uniqueTimeRangesForDay:self.selectedDay];
        NSArray *eventsByTimeRange = [self eventsSortedByTimeRange:[self eventsForDay]
                                               withUniqueTimeRange:uniqueTimeSlotForDay];
        [self updateActualEventIndexPathForTimeRange:eventsByTimeRange];
        dispatch_async(dispatch_get_main_queue(), ^{
//            
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            strongSelf.eventsByTimeRange = eventsByTimeRange;
            [strongSelf.tableView reloadData];
            [strongSelf.tableView scrollToRowAtIndexPath:strongSelf.actualEventIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        });
    });
}

- (void)reloadEvents
{
    [self loadEvents];
}


- (NSArray *)eventsForDay
{
    return [self.eventStrategy eventsForDay:self.selectedDay];
}



@end
