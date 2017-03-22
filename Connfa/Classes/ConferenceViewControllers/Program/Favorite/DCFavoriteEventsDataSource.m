
#import "DCFavoriteEventsDataSource.h"
#import "DCDayEventsDataSource.h"
#import "DCMainProxy+Additions.h"
#import "DCSocialEvent+DC.h"
@class DCMainEvent, DCSocialEvent, DCBof;

@implementation DCFavoriteEventsDataSource

- (void)loadEvents {
  __weak typeof(self) weakSelf = self;
  [self dataSourceStartUpdateEvents];
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        NSArray* eventsByTimeRange = [self favoriteEventsSource];
        dispatch_async(dispatch_get_main_queue(), ^{
          //
          __strong __typeof__(weakSelf) strongSelf = weakSelf;
          strongSelf.eventsByTimeRange = eventsByTimeRange;
          [strongSelf.tableView reloadData];

          [weakSelf dataSourceEndUpdateEvents];

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
      //[sections addObject:@{kDCTimeslotKEY : [self titleForClass:class]}];
      [sections addObjectsFromArray:eventsByTimeRange];
    }
  }
  
  NSArray *result = [self sortByTime:[NSArray arrayWithArray:sections]];
  
  return result;
}

- (NSArray *)sortByTime:(NSArray *)array {
  
  NSMutableArray *tempArr = [NSMutableArray new];
  
  for (NSDictionary *obj in array) {
    DCTimeRange *timeRange = [obj valueForKey:@"timeslot_key"];
    [tempArr addObject:timeRange];
  }
  
  NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                      sortDescriptorWithKey:@"from"
                                      ascending:YES];
  NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
  
  NSArray *sortedEventArray = [tempArr
                               sortedArrayUsingDescriptors:sortDescriptors];
  

  
  NSLog(@"!!!");

  return array;
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
//  if ([NSStringFromClass(class)
//          isEqualToString:NSStringFromClass([DCBof class])]) {
//    return @"BoFs";
//  } else if ([NSStringFromClass(class)
//                 isEqualToString:NSStringFromClass([DCMainEvent class])]) {
//    return @"Sessions";
//  } else {
//    return @"Social Events";
//  }
  return @"";
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
