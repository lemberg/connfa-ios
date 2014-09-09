//
//  DCMainProxy+Additions.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/21/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCMainProxy.h"

@interface DCMainProxy (Additions)

#pragma mark - 

- (NSArray*)daysForClass:(Class)eventClass;
- (NSArray*)eventsForDayNum:(NSInteger)dayNum forClass:(Class)eventClass;
- (NSArray*)uniqueTimeRangesForDayNum:(NSInteger)dayNum forClass:(Class)eventClass;
- (NSArray *)favoriteEvents;

#pragma mark -

@end
