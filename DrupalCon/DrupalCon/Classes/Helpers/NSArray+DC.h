//
//  NSArray+DC.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/21/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DCTimeRange;

@interface NSArray (DC)

- (NSArray*)objectsFromDictionaries;
- (NSArray*)sortedDates;
- (NSArray*)sortedByStartHour;
- (NSArray*)eventsForTimeRange:(DCTimeRange*)timeRange;
- (NSArray *)dictionaryByReplacingNullsWithStrings;

@end
