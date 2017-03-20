
#import "DCMainProxy.h"

@interface DCMainProxy (Additions)

#pragma mark -

- (NSArray*)daysForClass:(Class)eventClass;
- (NSArray*)daysForClass:(Class)eventClass predicate:(NSPredicate*)aPredicate;
- (NSArray*)eventsForDay:(NSDate*)day forClass:(Class)eventClass;
- (NSArray*)eventsForDay:(NSDate*)day
                forClass:(Class)eventClass
               predicate:(NSPredicate*)aPredicate;
- (NSArray*)uniqueTimeRangesForDay:(NSDate*)day forClass:(Class)eventClass;
- (NSArray*)uniqueTimeRangesForDay:(NSDate*)day
                          forClass:(Class)eventClass
                         predicate:(NSPredicate*)aPredicate;
- (NSArray*)favoriteEvents;
- (NSArray*)favoriteEventsWithPredicate:(NSPredicate*)aPredicate;

- (BOOL)isFilterCleared;

#pragma mark -

@end
