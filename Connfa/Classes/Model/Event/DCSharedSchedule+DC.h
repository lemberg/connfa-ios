//
//  DCSharedSchedule+DC.h
//  Connfa
//
//  Created by Oleh Kurnenkov on 4/28/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCSharedSchedule+CoreDataClass.h"
#import "DCManagedObjectUpdateProtocol.h"

@interface DCSharedSchedule (DC) <ManagedObjectUpdateProtocol>

extern NSString* kDCSchduleIdKey;
extern NSString* kDCSchdulesKey;
extern NSString* kDCCodeKey;

-(void)addEventsForIds:(NSArray *)ids;
+ (DCSharedSchedule *)getScheduleFromDictionary:(NSDictionary*)scheduleDictionary
                                      inContext:(NSManagedObjectContext*)context;
@end
