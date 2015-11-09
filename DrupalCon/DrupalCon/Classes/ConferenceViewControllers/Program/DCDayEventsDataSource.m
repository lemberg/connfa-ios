//
//  DCDayEventsDataSource.m
//  DrupalCon
//
//  Created by Olexandr on 3/12/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCDayEventsDataSource.h"


@interface DCDayEventsDataSource()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultController;

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
            
            // when this controller shows Current day
            if (strongSelf.actualEventIndexPath)
                [strongSelf moveTableToCurrentTime];
            
        });
    });
}

- (void) moveTableToCurrentTime
{
    self.tableView.alpha = 0;
    [self.tableView scrollToRowAtIndexPath:self.actualEventIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [UIView transitionWithView:self.tableView
                      duration:0.25
                       options:UIViewAnimationOptionCurveLinear
                    animations:^{
                        self.tableView.alpha = 1;
                    }
                    completion:nil];
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
