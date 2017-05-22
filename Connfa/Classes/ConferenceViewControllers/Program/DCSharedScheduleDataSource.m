//
//  DCSharedScheduleDataSource.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 5/22/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCSharedScheduleDataSource.h"
#import "DCMainProxy+Additions.h"

@implementation DCSharedScheduleDataSource

- (void)loadEvents:(BOOL)isFromPullToRefresh {
  __weak typeof(self) weakSelf = self;
  [self dataSourceStartUpdateEvents];
  dispatch_async(
                 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                   
                   NSArray* eventsByTimeRange = [self sharedEventsSource];
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                     //
                     __strong __typeof__(weakSelf) strongSelf = weakSelf;
                     strongSelf.eventsByTimeRange = eventsByTimeRange;
                     [strongSelf.tableView reloadData];
                     
                     [weakSelf dataSourceEndUpdateEvents];
                     
                     if(!isFromPullToRefresh && strongSelf.actualEventIndexPath){
                       [strongSelf.tableView
                        scrollToRowAtIndexPath:strongSelf.actualEventIndexPath
                        atScrollPosition:UITableViewScrollPositionTop
                        animated:NO];
                     }
                   });
                   
                 });
}

- (NSArray *)sortByTime:(NSArray *)array {
  NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    DCTimeRange * objectOne = [obj1 valueForKey:@"timeslot_key"];
    DCTimeRange * objectTwo = [obj2 valueForKey:@"timeslot_key"];
    return [objectOne.from compare:objectTwo.from];
  }];
  
  return sortedArray;
}

- (NSArray*)sharedEventsSource {
  NSMutableArray* sections = [NSMutableArray array];
  
  NSArray* uniqueTimeSlotForDay =
  [self uniqueTimeRangesForDay:self.selectedDay andEventClass:[DCEvent class]];
  NSArray* eventsByTimeRange =
  [self eventsSortedByTimeRange:[self eventsForDay]
            withUniqueTimeRange:uniqueTimeSlotForDay
                          class: [DCEvent class]];
  
  if ([eventsByTimeRange count]) {
    //[sections addObject:@{kDCTimeslotKEY : [self titleForClass:class]}];
    [sections addObjectsFromArray:eventsByTimeRange];
  }
  
  NSArray *result = [self sortByTime:[NSArray arrayWithArray:sections]];
  
  return result;
}

- (void)reloadEvents:(BOOL)isFromPullToRefresh {
  [self loadEvents:isFromPullToRefresh];
}

- (NSArray*)eventsForDay {
  return [self.eventStrategy eventsForDay:self.selectedDay];
}

- (NSArray*)eventsForDay:(NSDate*)day andClass:(Class)eventClass {
  return [[DCMainProxy sharedProxy] eventsForDay:day
                                        forClass:eventClass
                                        eventStrategy: self.eventStrategy
                                       predicate:self.eventStrategy.predicate];
}

- (NSArray*)uniqueTimeRangesForDay:(NSDate*)day
                     andEventClass:(Class)eventClass {
  return [[DCMainProxy sharedProxy]
          uniqueTimeRangesForDay:day
          forClass:eventClass
          eventStrategy:self.eventStrategy
          predicate:self.eventStrategy.predicate];
}


@end
