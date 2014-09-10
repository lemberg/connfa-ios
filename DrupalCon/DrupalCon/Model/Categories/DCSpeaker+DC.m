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
#import "NSString+HTML.h"

const NSString * kDCSpeaker_speakers_key = @"speakers";
const NSString * kDCSpeaker_speakerId_key = @"speakerID";
const NSString * kDCSpeaker_name_key = @"name";
const NSString * kDCSpeaker_organization_key = @"organization";
const NSString * kDCSpeaker_jobTitle_key = @"jobTitle";
const NSString * kDCSpeaker_charact_key = @"charact";
const NSString * kDCSpeaker_firstName_key = @"firstName";
const NSString * kDCSpeaker_lastName_key = @"lastName";
const NSString * kDCSpeaker_twitterName_key = @"twitterName";
const NSString * kDCSpeaker_webSite_key = @"webSite";
const NSString * kDCSpeaker_avatarPath_key = @"avatarImageUrl";

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
        speaker.firstName = speakerDict[kDCSpeaker_firstName_key];
        speaker.lastName = speakerDict[kDCSpeaker_lastName_key];
        speaker.avatarPath = speakerDict[kDCSpeaker_avatarPath_key];
        speaker.twitterName = speakerDict[kDCSpeaker_twitterName_key];
        speaker.webSite = speakerDict[kDCSpeaker_webSite_key];
        speaker.name = [NSString stringWithFormat:@"%@ %@", speaker.firstName, speaker.lastName];
        speaker.organizationName = speakerDict[kDCSpeaker_organization_key];
        speaker.jobTitle = speakerDict[kDCSpeaker_jobTitle_key];
        speaker.characteristic = [speakerDict[kDCSpeaker_charact_key] kv_decodeHTMLCharacterEntities];
    }
}

@end
