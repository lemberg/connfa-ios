//
//  DCEventStrategy.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 9/9/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCEventStrategy.h"
#import "DCMainProxy+Additions.h"

@interface DCEventStrategy ()

@property (nonatomic, strong) Class eventClass;

@end

@implementation DCEventStrategy

- (instancetype)initWithStrategy:(EDCEventStrategy)strategy
{
    self = [super init];
    if (self)
    {
        _strategy = strategy;
        switch (_strategy)
        {
            case EDCEventStrategyPrograms:
                _eventClass = [DCProgram class];
                break;
                
            case EDCEventStrategyBofs:
                _eventClass = [DCBof class];
                break;
                
            default:
                break;
        }
    }
    return self;
}

- (NSArray*)days
{
    return [[DCMainProxy sharedProxy] daysForClass:_eventClass];
}

- (NSArray*)eventsForDayNum:(NSInteger)dayNumber
{
    return [[DCMainProxy sharedProxy] eventsForDayNum:dayNumber forClass:_eventClass];
}

- (NSArray*)uniqueTimeRangesForDayNum:(NSInteger)dayNumber
{
    return [[DCMainProxy sharedProxy] uniqueTimeRangesForDayNum:dayNumber forClass:_eventClass];
}

@end
