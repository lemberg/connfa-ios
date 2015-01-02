//
//  DCCalendarManager.m
//  DrupalCon
//
//  Created by Oleg Stasula on 02.01.15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCCalendarManager.h"
#import <EventKit/EventKit.h>
#import "DCEvent+DC.h"
#import "DCTimeRange+DC.h"
#import "DCTime+DC.h"

@implementation DCCalendarManager

+ (void)addEventWithItem:(DCEvent *)event {
    EKEventStore *eventStore = [EKEventStore new];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent
                               completion:^(BOOL granted, NSError *error) {
                                   if (granted) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           EKEvent *calEvent  = [EKEvent eventWithEventStore:eventStore];
                                           calEvent.title     = event.name;
                                           calEvent.startDate = [event startDate];
                                           calEvent.endDate   = [event endDate];
                                           
                                           [calEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
                                           
                                           NSError *err = nil;
                                           [eventStore saveEvent:calEvent
                                                            span:EKSpanThisEvent
                                                           error:&err];
                                           if (err)
                                               NSLog(@"Error during adding event to a calendar %@", err);                                       
                                       });
                                   }
                               }];
}

+ (void)removeEventOfItem:(DCEvent *)event {
    EKEventStore *eventStore = [EKEventStore new];
    NSPredicate *predicate   = [eventStore predicateForEventsWithStartDate:[event startDate]
                                                                   endDate:[event endDate]
                                                                 calendars:@[ [eventStore defaultCalendarForNewEvents] ]];
    for (EKEvent *e in [eventStore eventsMatchingPredicate:predicate]) {
        if ([e.title isEqualToString:event.name]) {
            NSError *error;
            [eventStore removeEvent:e
                               span:EKSpanThisEvent
                              error:&error];
            if (error)
                NSLog(@"Error during removing event from a calendar %@", error);
        }
    }
}

@end
