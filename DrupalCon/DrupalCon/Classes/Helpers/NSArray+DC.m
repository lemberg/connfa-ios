//
//  NSArray+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/21/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "NSArray+DC.h"
#import "DCTime+DC.h"
#import "DCTimeRange+DC.h"
#import "DCEvent+DC.h"
#import "NSDictionary+DC.h"

@implementation NSArray (DC)

- (NSArray*)objectsFromDictionaries
{
    if (self.count>0)
    {
        if ([self.firstObject isKindOfClass:[NSDictionary class]])
        {
            NSArray* keys = [(NSDictionary*)self.firstObject allKeys];
            if (keys.count == 1)
            {
                NSString * key = keys.firstObject;
                NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.count];
                for (NSDictionary * dict in self)
                {
                    [result addObject:dict[key]];
                }
                return result;
            }
        }
    }
    NSLog(@"WRONG! method used");
    return self;
}

- (NSArray*)sortedDates
{
    if (self.count) {
        if ([self.firstObject isKindOfClass:[NSDate class]])
        {
            NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
            return [self sortedArrayUsingDescriptors:@[descriptor]];
        }
    }
    NSLog(@"WRONG! array for sort. dates");
    return self;
}

- (NSArray*)sortedByStartHour
{
    if (self.count) {
        if ([self.firstObject isKindOfClass:[DCTimeRange class]])
        {
            NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"self"
                                                                         ascending:YES
                                                                        comparator:^NSComparisonResult(id obj1, id obj2) {
                                                                            DCTime* time1 = [(DCTimeRange*)obj1 from];
                                                                            DCTime* time2 = [(DCTimeRange*)obj2 from];
                                                                            
                                                                            NSComparisonResult fromResult = [self DC_checkTime1:time1 time2:time2];
                                                                            
                                                                            if (fromResult != NSOrderedSame)
                                                                            {
                                                                                return fromResult;
                                                                            }
                                                                            DCTime* endTime1 = [(DCTimeRange*)obj1 from];
                                                                            DCTime* endTime2 = [(DCTimeRange*)obj2 from];
                                                                            
                                                                            NSComparisonResult toResult = [self DC_checkTime1:endTime1 time2:endTime2];
                                                                        
                                                                            return toResult;
                                                                        }];
            return [self sortedArrayUsingDescriptors:@[descriptor]];
        }
    }
    NSLog(@"WRONG! array for sort. timeRange");
    return self;
}

- (NSArray*)eventsForTimeRange:(DCTimeRange *)timeRange
{
    if (self.count) {
        if ([self.firstObject isKindOfClass:[DCEvent class]])
        {
            NSPredicate * predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                return [(DCTimeRange*)[(DCEvent*)evaluatedObject timeRange] isEqualTo:timeRange];
            }];
            return [self filteredArrayUsingPredicate:predicate];
        }
    }
    NSLog(@"WRONG! array for sort. dates");
    return self;
}


#pragma mark - private

- (NSComparisonResult)DC_checkTime1:(DCTime*)time1 time2:(DCTime*)time2
{
    if ([time1.hour integerValue] > [time2.hour integerValue])
    {
        return (NSComparisonResult)NSOrderedDescending;
    }
    else if ([time1.hour integerValue] < [time2.hour integerValue])
    {
        return (NSComparisonResult)NSOrderedAscending;
    }
    else
    {
        if ([time1.minute integerValue] > [time2.minute integerValue])
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        else if ([time1.minute integerValue] < [time2.minute integerValue])
        {
            return (NSComparisonResult)NSOrderedAscending;
        }
    }
    return NSOrderedSame;
}


- (NSArray *)dictionaryByReplacingNullsWithStrings  {
    NSMutableArray *replaced = [self mutableCopy];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    for (int idx = 0; idx < [replaced count]; idx++) {
        id object = [replaced objectAtIndex:idx];
        if (object == nul) [replaced replaceObjectAtIndex:idx withObject:blank];
        else if ([object isKindOfClass:[NSDictionary class]]) [replaced replaceObjectAtIndex:idx withObject:[object dictionaryByReplacingNullsWithStrings]];
        else if ([object isKindOfClass:[NSArray class]]) [replaced replaceObjectAtIndex:idx withObject:[object dictionaryByReplacingNullsWithStrings]];
    }
    return [replaced copy];
}
@end
