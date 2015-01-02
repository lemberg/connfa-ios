//
//  DCCalendarManager.h
//  DrupalCon
//
//  Created by Oleg Stasula on 02.01.15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCEvent.h"

@class DCEvent;

@interface DCCalendarManager : NSObject

+ (void)addEventWithItem:(DCEvent *)event;
+ (void)removeEventOfItem:(DCEvent *)event;

@end
