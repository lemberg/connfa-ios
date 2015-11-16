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



#import "DCFavoriteEventsDataSource.h"
#import "DCDayEventsDataSource.h"
#import "DCMainProxy+Additions.h"
#import "DCSocialEvent+DC.h"
@class DCMainEvent, DCSocialEvent, DCBof;

@implementation DCFavoriteEventsDataSource

- (void)loadEvents {
  __weak typeof(self) weakSelf = self;
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        NSArray* eventsByTimeRange = [self favoriteEventsSource];
        dispatch_async(dispatch_get_main_queue(), ^{
          //
          __strong __typeof__(weakSelf) strongSelf = weakSelf;
          strongSelf.eventsByTimeRange = eventsByTimeRange;
          [strongSelf.tableView reloadData];
          [strongSelf.tableView
              scrollToRowAtIndexPath:strongSelf.actualEventIndexPath
                    atScrollPosition:UITableViewScrollPositionTop
                            animated:NO];
        });
      });
}
// kDCTimeslotKEY
// kDCTimeslotEventKEY

- (NSArray*)favoriteEventsSource {
  NSArray* eventClasses =
      @[ [DCMainEvent class], [DCBof class], [DCSocialEvent class] ];

  NSMutableArray* sections = [NSMutableArray array];
  for (Class class in eventClasses) {
    NSArray* uniqueTimeSlotForDay =
        [self uniqueTimeRangesForDay:self.selectedDay andEventClass:class];
    NSArray* eventsByTimeRange =
        [self eventsSortedByTimeRange:[self eventsForDay]
                  withUniqueTimeRange:uniqueTimeSlotForDay];
    if ([eventsByTimeRange count]) {
      [sections addObject:@{kDCTimeslotKEY : [self titleForClass:class]}];
      [sections addObjectsFromArray:eventsByTimeRange];
    }
  }
  return [NSArray arrayWithArray:sections];
}

- (NSString*)titleForSectionAtIdexPath:(NSInteger)section {
  if (section >= [self.eventsByTimeRange count]) {
    return nil;
  }
  NSDictionary* sectionsInfo = self.eventsByTimeRange[section];
  NSArray* events = sectionsInfo[kDCTimeslotEventKEY];
  return ![events count] ? sectionsInfo[kDCTimeslotKEY] : nil;
}

- (NSString*)titleForClass:(Class) class {
  if ([NSStringFromClass(class)
          isEqualToString:NSStringFromClass([DCBof class])]) {
    return @"Bofs";
  } else if ([NSStringFromClass(class)
                 isEqualToString:NSStringFromClass([DCMainEvent class])]) {
    return @"Sessions";
  } else {
    return @"Social Events";
  }

}

- (void)reloadEvents {
  [self loadEvents];
}

- (NSArray*)eventsForDay {
  return [self.eventStrategy eventsForDay:self.selectedDay];
}

- (NSArray*)eventsForDay:(NSDate*)day andClass:(Class)eventClass {
  return [[DCMainProxy sharedProxy] eventsForDay:day
                                        forClass:eventClass
                                       predicate:self.eventStrategy.predicate];
}

- (NSArray*)uniqueTimeRangesForDay:(NSDate*)day
                     andEventClass:(Class)eventClass {
  return [[DCMainProxy sharedProxy]
      uniqueTimeRangesForDay:day
                    forClass:eventClass
                   predicate:self.eventStrategy.predicate];
}

@end
