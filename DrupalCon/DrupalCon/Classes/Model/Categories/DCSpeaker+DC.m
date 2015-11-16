//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in
//   all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE
//  SOFTWARE.
//

#import "DCSpeaker+DC.h"
#import "DCMainProxy.h"
#import "NSDictionary+DC.h"
#import "NSString+HTML.h"
#import "NSManagedObject+DC.h"

const NSString* kDCSpeakersKey = @"speakers";
const NSString* kDCSpeakerIdKey = @"speakerId";
const NSString* kDCSpeakerOrganizationKey = @"organizationName";
const NSString* kDCSpeakerJobTitleKey = @"jobTitle";
const NSString* kDCSpeakerCharactKey = @"characteristic";
const NSString* kDCSpeakerFirstNameKey = @"firstName";
const NSString* kDCSpeakerLastNameKey = @"lastName";
const NSString* kDCSpeakerTwitterNameKey = @"twitterName";
const NSString* kDCSpeakerWebSiteKey = @"webSite";
const NSString* kDCSpeakerAvatarImageURLKey = @"avatarImageURL";

@implementation DCSpeaker (DC)

#pragma mark - ManagedObjectUpdateProtocol

+ (void)updateFromDictionary:(NSDictionary*)speakers
                   inContext:(NSManagedObjectContext*)context {
  for (NSDictionary* dictionary in speakers[kDCSpeakersKey]) {
    DCSpeaker* speaker = (DCSpeaker*)[[DCMainProxy sharedProxy]
        objectForID:[dictionary[kDCSpeakerIdKey] intValue]
            ofClass:[DCSpeaker class]
          inContext:context];

    if (!speaker)  // then create
    {
      speaker = [DCSpeaker createManagedObjectInContext:context];
    }

    if ([dictionary[kDCParseObjectDeleted] intValue] == 1)  // remove
    {
      [[DCMainProxy sharedProxy] removeItem:speaker];
    } else  // update
    {
      speaker.speakerId = dictionary[kDCSpeakerIdKey];
      speaker.firstName = dictionary[kDCSpeakerFirstNameKey];
      speaker.lastName = dictionary[kDCSpeakerLastNameKey];
      speaker.avatarPath = dictionary[kDCSpeakerAvatarImageURLKey];
      speaker.twitterName = dictionary[kDCSpeakerTwitterNameKey];
      speaker.webSite = dictionary[kDCSpeakerWebSiteKey];
      speaker.name = [NSString
          stringWithFormat:@"%@ %@", speaker.firstName, speaker.lastName];
      speaker.organizationName = dictionary[kDCSpeakerOrganizationKey];
      speaker.jobTitle = dictionary[kDCSpeakerJobTitleKey];
      speaker.characteristic =
          [dictionary[kDCSpeakerCharactKey] kv_decodeHTMLCharacterEntities];
      speaker.order = [NSNumber
          numberWithFloat:[dictionary[kDCParseObjectOrderKey] floatValue]];
      speaker.sectionKey =
          [DCSpeaker firstUpperLetter:dictionary[kDCSpeakerFirstNameKey]];
    }
  }
}

+ (NSString*)firstUpperLetter:(NSString*)source {
  NSString* upperCaseSource = [source uppercaseString];

  // support UTF-16:
  NSString* firstLetter =
      [upperCaseSource substringWithRange:NSMakeRange(0, 1)];
  return firstLetter;
}

+ (NSString*)idKey {
  return (NSString*)kDCSpeakerIdKey;
}

@end
