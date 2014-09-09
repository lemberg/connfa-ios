//
//  DCSpeaker+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/27/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCSpeaker+DC.h"
#import "DCMainProxy.h"
#import "NSDictionary+DC.h"

const NSString * kDCSpeaker_speakers_key = @"speakers";
const NSString * kDCSpeaker_speakerId_key = @"speakerId";
const NSString * kDCSpeaker_name_key = @"name";
const NSString * kDCSpeaker_organization_key = @"organization";
const NSString * kDCSpeaker_jobTitle_key = @"jobTitle";
const NSString * kDCSpeaker_charact_key = @"charact";


@implementation DCSpeaker (DC)

+ (void)parseFromJSONData:(NSData*)jsonData
{
    NSError * err = nil;
    NSDictionary * speakers = [NSJSONSerialization JSONObjectWithData:jsonData
                                                           options:kNilOptions
                                                             error:&err];
    speakers = [speakers dictionaryByReplacingNullsWithStrings];
    if (err)
    {
        NSLog(@"WRONG! json");
        return;
    }
    
    for (NSDictionary * speakerDict in speakers[kDCSpeaker_speakers_key])
    {
        DCSpeaker * speaker = [[DCMainProxy sharedProxy] createSpeaker];
        speaker.speakerId = speakerDict[kDCSpeaker_speakerId_key];
        speaker.name = speakerDict[kDCSpeaker_name_key];
        speaker.organizationName = speakerDict[kDCSpeaker_organization_key];
        speaker.jobTitle = speakerDict[kDCSpeaker_jobTitle_key];
        speaker.characteristic = speakerDict[kDCSpeaker_charact_key];
    }
}

@end
