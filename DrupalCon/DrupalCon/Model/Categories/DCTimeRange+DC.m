//
//  DCTimeRange+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/21/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCTimeRange+DC.h"
#import "DCTime+DC.h"
#import "DCMainProxy.h"

@implementation DCTimeRange (DC)

- (NSString*)stringValue
{
    return [NSString stringWithFormat:@"%@ to %@", [self.from stringValue], [self.to stringValue]];
}

- (void)setFrom:(NSString *)from to:(NSString *)to
{
    self.from = [[DCMainProxy sharedProxy] createTime];
    [self.from setTime:from];
    self.to = [[DCMainProxy sharedProxy] createTime];
    [self.to setTime:to];
}

- (BOOL)isEqualTo:(DCTimeRange *)timeRange
{
    BOOL result = YES;
    if (![[timeRange.from stringValue] isEqualToString:[self.from stringValue]])
    {
        result = NO;
    }
    if (![[timeRange.to stringValue] isEqualToString:[self.to stringValue]])
    {
        result = NO;
    }
    return result;
}
- (NSString*)description
{
    return [self stringValue];
}

@end
