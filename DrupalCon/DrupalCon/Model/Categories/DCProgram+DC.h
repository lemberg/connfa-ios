//
//  DCProgram+DC.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCProgram.h"

extern NSString * kDCProgram_programEvents_key;

typedef NS_ENUM (int, DCEventType) {
    DC_EVENT_NONE = 0,
    DC_EVENT_SPEACH = 1,
    DC_EVENT_SPEACH_OF_DAY = 2,
    DC_EVENT_COFEE_BREAK = 3,
    DC_EVENT_LUNCH = 4,
};

@interface DCProgram (DC)

@end
