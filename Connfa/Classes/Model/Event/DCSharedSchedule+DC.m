//
//  DCSharedSchedule+DC.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 4/28/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCSharedSchedule+DC.h"
#import "DCEvent+DC.h"
#import "NSManagedObject+DC.h"

const NSString* kDCSchduleIdKey = @"scheduleId";
const NSString* kDCSchdulesKey = @"schedules";
const NSString* kDCCodeKey = @"code";

@implementation DCSharedSchedule (DC)

-(void)addEventsForIds:(NSArray *)ids{
    for (NSNumber* eventIdNum in ids) {
        DCEvent* event = (DCEvent*)
        [[DCMainProxy sharedProxy] objectForID:[eventIdNum intValue]
                                       ofClass:[DCEvent class]
                                     inContext:self.managedObjectContext];
        if (!event) {
            event =
            [DCEvent createManagedObjectInContext:self.managedObjectContext];
            event.eventId = eventIdNum;
        }
        [event addSchedulesObject:self];
        [self addEventsObject:event];
    }
}

+ (void)updateFromDictionary:(NSDictionary*)schedules
                   inContext:(NSManagedObjectContext*)context{
    for (NSDictionary* scheduleDictionary in schedules[kDCSchdulesKey]) {
        DCSharedSchedule* schedule = (DCSharedSchedule*)
        [[DCMainProxy sharedProxy] objectForID:[scheduleDictionary[kDCCodeKey] intValue]
                                       ofClass:[DCSharedSchedule class]
                                     inContext:context];
        if(!schedule){
            //TODO: create schedule
        }
        [schedule addEventsForIds:(NSArray *)scheduleDictionary[kDCEventsKey]];
    }
}

+ (NSString*)idKey {
    return (NSString*)kDCSchduleIdKey;
}

@end
