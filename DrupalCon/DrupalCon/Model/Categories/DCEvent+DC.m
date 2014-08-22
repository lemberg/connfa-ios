//
//  DCEvent+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCEvent+DC.h"
#import "DCTimeRange+DC.h"

const NSString * kDCEvent_days_key = @"days";
const NSString * kDCEvent_date_key = @"date";
const NSString * kDCEvent_events_key = @"events";
const NSString * kDCEvent_from_key = @"from";
const NSString * kDCEvent_to_key = @"to";
const NSString * kDCEvent_type_key = @"type";
const NSString * kDCEvent_name_key = @"name";
const NSString * kDCEvent_speaker_key = @"speaker";
const NSString * kDCEvent_track_key = @"track";
const NSString * kDCEvent_experienceLevel_key = @"experience_level";

@implementation DCEvent (DC)


+ (void)parceFromJSONData:(NSData *)jsonData
{

}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ (%@ %@)", self.name, self.date, [self.timeRange stringValue]];
}

@end
