//
//  DCEvent.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTimeRange.h"

typedef NS_ENUM (int, DCEventType) {
    DC_EVENT_SPEACH = 0,
    DC_EVENT_SPEACH_OF_DAY = 1,
    DC_EVENT_COFEE_BREAK = 2,
    DC_EVENT_LUNCH = 3,
};

@interface DCEvent : NSObject
@property (nonatomic) DCEventType eventType;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *speaker;
@property (nonatomic, strong) NSString *track;
@property (nonatomic, strong) NSString *experienceLevel;
@property (nonatomic, strong) DCTimeRange *time;
@property (nonatomic) BOOL addedToMySchedule;
@end
