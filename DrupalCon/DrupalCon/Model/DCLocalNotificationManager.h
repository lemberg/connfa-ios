//
//  DCLocalNotificationManager.h
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/16/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DCEvent;

@interface DCLocalNotificationManager : NSObject

+ (void)scheduleNotificationWithItem:(DCEvent *)item interval:(int)minutesBefore;
+ (void)cancelLocalNotificationWithId:(NSNumber *)eventID;

@end
