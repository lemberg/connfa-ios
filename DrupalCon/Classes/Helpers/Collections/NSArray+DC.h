
#import <Foundation/Foundation.h>

@class DCTimeRange;

@interface NSArray (DC)

- (NSArray*)objectsFromDictionaries;
- (NSArray*)sortedDates;
- (NSArray*)sortedByStartHour;
- (NSArray*)eventsForTimeRange:(DCTimeRange*)timeRange;
- (NSArray*)dictionaryByReplacingNullsWithStrings;
- (NSArray*)sortedByKey:(NSString*)key;

@end
