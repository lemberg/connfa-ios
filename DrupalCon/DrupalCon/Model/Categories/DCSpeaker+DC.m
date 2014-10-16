//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
        @throw [NSException exceptionWithName:INVALID_JSON_EXCEPTION reason:@"Problem in json structure" userInfo:nil];
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

#pragma mark - parseProtocol

+ (BOOL)successParceJSONData:(NSData *)jsonData idsForRemove:(NSArray *__autoreleasing *)idsForRemove
{
    NSError * err = nil;
    NSDictionary * speakers = [NSJSONSerialization JSONObjectWithData:jsonData
                                                           options:kNilOptions
                                                             error:&err];
    speakers = [speakers dictionaryByReplacingNullsWithStrings];
    
    if (err)
    {
        @throw [NSException exceptionWithName:INVALID_JSON_EXCEPTION reason:@"Problem in json structure" userInfo:nil];
        return NO;
    }
    
    //adding
    for (NSDictionary * speakerDict in speakers[kDCParcesObjectsToAdd])
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
    
    
    //colelct objects ids for removing
    if (speakers[kDCParcesObjectsToRemove])
    {
        NSMutableArray * idsForRemoveMut = [[NSMutableArray alloc] initWithCapacity:[(NSArray*)speakers[kDCParcesObjectsToRemove] count]];
        for (NSDictionary * idDictiuonary in speakers[kDCParcesObjectsToRemove])
        {
            [idsForRemoveMut addObject:idDictiuonary[kDCSpeaker_speakerId_key]];
        }
        * idsForRemove  = [[NSArray alloc] initWithArray:idsForRemoveMut];
    }
    
    return YES;
}

+ (NSString*)idKey
{
    return (NSString*)kDCSpeaker_speakerId_key;
}

@end
