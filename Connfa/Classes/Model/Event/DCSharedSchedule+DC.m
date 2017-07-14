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
#import "DCCoreDataStore.h"

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
    if(schedules[kDCSchdulesKey]){
      for (NSDictionary* scheduleDictionary in schedules[kDCSchdulesKey]) {
        [self addScheduleFromDictionary:scheduleDictionary andContext:context];
      }
    } else {
      [self addScheduleFromDictionary:schedules andContext:context];
    }
    if([DCCoreDataStore mainQueueContext]){
    [[DCCoreDataStore defaultStore] saveWithCompletionBlock:nil];
    }
}

+ (void)addScheduleFromDictionary:(NSDictionary *)scheduleDictionary
                       andContext:(NSManagedObjectContext*)context {
  if(scheduleDictionary){
    DCSharedSchedule* schedule = [self getScheduleFromDictionary:scheduleDictionary inContext:context];
    if(!schedule){
      schedule = [DCSharedSchedule createManagedObjectInContext:context];
      schedule.scheduleId = [scheduleDictionary objectForKey:kDCCodeKey];
    }
    NSLog(@"%@", schedule.scheduleId);
    schedule.isMySchedule = [NSNumber numberWithBool:NO];
    [schedule removeEvents:schedule.events];
    [schedule addEventsForIds:(NSArray *)scheduleDictionary[kDCEventsKey]];
  }
}

+ (DCSharedSchedule *)getScheduleFromDictionary:(NSDictionary*)scheduleDictionary
                                      inContext:(NSManagedObjectContext*)context{
    NSNumber* code = scheduleDictionary[kDCCodeKey];
    DCSharedSchedule* schedule = (DCSharedSchedule*)
    [[DCMainProxy sharedProxy] objectForID:[code intValue]
                                   ofClass:[DCSharedSchedule class]
                                 inContext:context];
    return schedule;
}

+ (NSString*)idKey {
    return (NSString*)kDCSchduleIdKey;
}

@end
