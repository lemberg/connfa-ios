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

- (void)setFrom:(NSString *)from to:(NSString *)to
{
    self.from = [[DCMainProxy sharedProxy] createTime];
    [self.from setTime:from];
    self.to = [[DCMainProxy sharedProxy] createTime];
    [self.to setTime:to];
}

@end
