//
//  DCLocalNotificationManager.m
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/16/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCLocalNotificationManager.h"
#import "DCEvent.h"
#import "DCTime.h"
#import "DCTimeRange.h"

@implementation DCLocalNotificationManager

static  const NSString * kEventId = @"EventID";

+ (void)scheduleNotificationWithItem:(DCEvent *)item interval:(int)minutesBefore
{
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    
    NSDate *date = item.date;//[NSDate date];
    
    unsigned unitFlags = NSYearCalendarUnit |
                         NSMonthCalendarUnit |
                         NSDayCalendarUnit |
                         NSCalendarUnitDay |
                         NSCalendarUnitHour |
                         NSCalendarUnitMinute ;
   
    NSDateComponents *eventDate = [calendar components:unitFlags fromDate:date];
    [dateComps setDay:[eventDate day]];
    [dateComps setMonth:eventDate.month];
    [dateComps setYear:eventDate.year];
    [dateComps setHour:[item.timeRange.from.hour integerValue]];
    [dateComps setMinute:[item.timeRange.from.minute integerValue]];
    
    NSDate *itemDate = [calendar dateFromComponents:dateComps];
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    
    localNotif.fireDate = [itemDate dateByAddingTimeInterval:-(minutesBefore*60)];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    NSString *alertBody = [NSString
                           stringWithFormat:@"%@ in %i minutes.\nPlace: %@",
                           item.name,
                           minutesBefore,
                           item.place];
    localNotif.alertBody = alertBody;
    
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:item.eventID  forKey:kEventId];
    localNotif.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

+ (void)cancelLocalNotificationWithId:(NSNumber *)eventID
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *events = [app scheduledLocalNotifications];
    for (UILocalNotification *event in events) {
        if ([event.userInfo[kEventId] integerValue] == [eventID integerValue]) {
            [app cancelLocalNotification: event];
        }
    }
}

@end
