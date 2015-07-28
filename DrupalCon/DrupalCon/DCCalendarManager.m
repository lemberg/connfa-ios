//
//  DCCalendarManager.m
//  DrupalCon
//
//  Created by Oleg Stasula on 02.01.15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCCalendarManager.h"
#import <EventKit/EventKit.h>
#import "DCTimeRange+DC.h"
#import "DCTime+DC.h"
#import "DCEvent+DC.h"
#import "DCCoreDataStore.h"

NSString * kCalendarIdKey = @"CalendarIdKey";
NSString * calendarTitle = @"DrupalCon events";


@implementation DCCalendarManager

static EKEventStore *eventStore;

+ (void) initialize {
    eventStore = [EKEventStore new];
}

+ (EKCalendar*) defaultCalendar {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * calendarId = [defaults stringForKey:kCalendarIdKey];
    
    EKCalendar* calendar = [self findCalendar:calendarId title:calendarTitle];
    
    if (!calendarId && calendar) {
        [self removeCalendar:calendar];
        calendar = nil;
    }
    
    if (calendar == nil) {
        calendar = [self createNewCalendar];
    }
    
    return calendar;
}

+ (EKCalendar*) findCalendar: (NSString*)calendarId title:(NSString*)calendarTitle{
    
        //instead of getting calendar by identifier
        //get all calendars and check matching in the cycle
        //workaround caused by bug: http://stackoverflow.com/questions/28258204/error-getting-shared-calendar-invitations-for-entity-types-3-xcode-6-1-1-ekcal
    
    NSArray *allCalendars = [eventStore calendarsForEntityType:EKEntityTypeEvent];
    for (EKCalendar *calendar in allCalendars) {
        if ([calendar.calendarIdentifier isEqualToString:calendarId] || [calendar.title isEqualToString:calendarTitle]) {
            return calendar;
        }
    }
    
    return nil;
}

+ (EKCalendar*) createNewCalendar {
    EKCalendar *calendar;
    EKSource *defaultSource = [eventStore defaultCalendarForNewEvents].source;

        // create new calendar in Default source
    calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:eventStore];
    calendar.title = calendarTitle;
    calendar.source = defaultSource;
    
    NSError* error = nil;
    [eventStore saveCalendar:calendar commit:YES error:&error];
    
    if (error && error.code == 17) {
        [[[UIAlertView alloc] initWithTitle:@"Attention"
                                    message:@"DrupalCon calendar was not created because app does not have rights to access your calendar account. Go to Settings->Mail,Contacts,Calendars->Account and turn off Calendar switcher. Or use iCloud account for calendar."
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
    
    if (!error) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:calendar.calendarIdentifier forKey:kCalendarIdKey];
        [userDefaults synchronize];
    }

    return calendar;
}

+ (void) removeCalendar: (EKCalendar*)calendar {
    NSError *error = nil;
    
    BOOL result = [eventStore removeCalendar:calendar commit:YES error:&error];
    if (!result) {
        NSLog(@"Deleting calendar failed: %@.", error);
    }
}

+ (void)addEventWithItem:(DCEvent *)event interval:(int)minutesBefore {
    [eventStore requestAccessToEntityType:EKEntityTypeEvent
                               completion:^(BOOL granted, NSError *error) {
                                   if (granted) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           EKEvent *calEvent  = [EKEvent eventWithEventStore:eventStore];
                                           calEvent.title     = event.name;
                                           calEvent.location = event.place;
                                           calEvent.startDate = [event startDate];
                                           calEvent.endDate   = [event endDate];
                                           calEvent.calendar = [self defaultCalendar];

                                           NSTimeInterval interval = -(minutesBefore * 60.f);
                                           EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset: interval];
                                           [calEvent addAlarm:alarm];
                                           
                                           NSError *err = nil;
                                           [eventStore saveEvent:calEvent
                                                            span:EKSpanThisEvent
                                                           error:&err];
                                           
                                           event.calendarId = calEvent.eventIdentifier;
                                           [[DCCoreDataStore defaultStore] saveWithCompletionBlock:nil];
                                           
                                           if (err)
                                               NSLog(@"Error during adding event to a calendar %@", err);                                       
                                       });
                                   } else {
                                       [[[UIAlertView alloc] initWithTitle:@"Attention"
                                                                   message:@"Event was not added to Calendar. Please, go to Settings and allow access to Calendar application."
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Ok"
                                                         otherButtonTitles:nil] show];

                                   }
                               }];
}

+ (void)removeEventOfItem:(DCEvent *)event {
    EKEvent *calendarEvent = [eventStore eventWithIdentifier:event.calendarId];
    
    if (calendarEvent) {
        NSError *error;
        [eventStore removeEvent:calendarEvent
                           span:EKSpanThisEvent
                          error:&error];
        if (error)
            NSLog(@"Error during removing event from a calendar %@", error);
    }
}

@end
