//
//  DCEventStrategy.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 9/9/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCEvent+DC.h"
#import "DCProgram+DC.h"
#import "DCBof.h"

typedef enum {
    EDCEventStrategyPrograms = 0,
    EDCEventStrategyBofs =1
}EDCEventStrategy;

@interface DCEventStrategy : NSObject

@property (nonatomic) EDCEventStrategy strategy;

- (instancetype)initWithStrategy:(EDCEventStrategy)strategy;

- (NSArray*)days;
- (NSArray*)eventsForDayNum:(NSInteger)dayNumber;
- (NSArray*)uniqueTimeRangesForDayNum:(NSInteger)dayNumber;

@end
