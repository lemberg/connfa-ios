//
//  DCAppSettings+DC.m
//  DrupalCon
//
//  Created by Olexandr on 7/7/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCAppSettings+DC.h"
#import "NSManagedObject+DC.h"

@implementation DCAppSettings(DC)
static NSString *kDCAppSettingsTimeZoneValue = @"timezone";
static NSString *kDCAppSettings = @"settings";

+ (void)updateFromDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context
{
    NSArray * settings = [[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCAppSettings class] inContext:context];
    DCAppSettings *appSettings;
    if (settings.count == 0)
    {
        appSettings = [DCAppSettings createManagedObjectInContext:context];
    }
    else if (settings.count > 1) // There should be one info instance only.
    {
        NSLog(@"WARNING! info is not unique");
        appSettings = [settings lastObject];
    }
    else
    {
        appSettings = [settings lastObject];
    }
    
    if ([[dictionary allKeys] containsObject:kDCAppSettings])
    {
        appSettings.eventTimeZone = @([dictionary[kDCAppSettings][kDCAppSettingsTimeZoneValue] integerValue]);
    }
    

}
@end
