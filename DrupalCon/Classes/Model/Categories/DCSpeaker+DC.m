
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
      speaker.firstName = [dictionary[kDCSpeakerFirstNameKey] trimmingWhiteSpace];
      speaker.lastName = [dictionary[kDCSpeakerLastNameKey] trimmingWhiteSpace];
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
