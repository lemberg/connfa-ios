
#import "DCMainProxy.h"
#import "DCEventStrategy.h"

@interface DCMainProxy (Additions)

#pragma mark -

- (NSArray*)daysForClass:(Class)eventClass;
- (NSArray*)daysForClass:(Class)eventClass predicate:(NSPredicate*)aPredicate;
- (NSArray*)eventsForDay:(NSDate*)day forClass:(Class)eventClass;
- (NSArray*)eventsForDay:(NSDate*)day
                forClass:(Class)eventClass
           eventStrategy:(DCEventStrategy *)eventStrategy
               predicate:(NSPredicate*)aPredicate;
- (NSArray*)uniqueTimeRangesForDay:(NSDate*)day forClass:(Class)eventClass;
- (NSArray*)uniqueTimeRangesForDay:(NSDate*)day
                          forClass:(Class)eventClass
                     eventStrategy:(DCEventStrategy *)eventStrategy
                         predicate:(NSPredicate*)aPredicate;
- (NSArray*)favoriteEvents;
- (NSArray*)favoriteEventsWithPredicate:(NSPredicate*)aPredicate;

- (BOOL)isFilterCleared;

#pragma mark - Schedules
-(void)updateSchedule;
-(void)getSchedules:(NSArray*)codes callback:(void (^)(BOOL, DCSharedSchedule*))callback;
- (NSArray*)getAllSharedSchedules;
-(NSArray *)getSchedulesIds;
@end
