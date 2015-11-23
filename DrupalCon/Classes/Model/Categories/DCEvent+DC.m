
#import "DCEvent+DC.h"
#import "DCTimeRange+DC.h"
#import "DCTime+DC.h"
#import "DCType+DC.h"
#import "DCSpeaker+DC.h"
#import "DCLevel+DC.h"
#import "DCTrack+DC.h"
#import "DCMainProxy+Additions.h"
#import "NSManagedObject+DC.h"

#import "NSString+HTML.h"
#import "UIImage+Extension.h"

const NSString* kDCEventsKey = @"events";
const NSString* kDCEventDaysKey = @"days";
const NSString* kDCEventDateKey = @"date";
const NSString* kDCEventFromKey = @"from";
const NSString* kDCEventToKey = @"to";
const NSString* kDCEventTypeKey = @"type";
const NSString* kDCEventNameKey = @"name";
const NSString* kDCEventLinkKey = @"link";
const NSString* kDCEventSpeakersKey = @"speakers";
const NSString* kDCEventTrackKey = @"track";
const NSString* kDCEventExperienceLevelKey = @"experienceLevel";
const NSString* kDCEventIdKey = @"eventId";
const NSString* kDCEventTextKey = @"text";
const NSString* kDCEventPlaceKey = @"place";
const NSString* kDCEventOrderKey = @"order";

@implementation DCEvent (DC)

- (NSArray*)speakersNames {
  NSMutableArray* speakerNames =
      [[NSMutableArray alloc] initWithCapacity:self.speakers.count];
  for (DCSpeaker* speaker in self.speakers) {
    [speakerNames addObject:(NSString*)speaker.name];
  }
  return speakerNames;
}

- (NSString*)description {
  return [NSString stringWithFormat:@"%@ (%@ %@)", self.name, self.date,
                                    [self.timeRange stringValue]];
}

- (NSInteger)getTypeID {
  return [self.type.typeID integerValue];
}

#pragma mark - Update protocol method
// Overload this method in child objects
+ (void)updateFromDictionary:(NSDictionary*)dictionary
                   inContext:(NSManagedObjectContext*)context;
{}

- (void)updateFromDictionary:(NSDictionary*)eventDict forData:(NSDate*)date {
  self.date = date;
  self.eventId = eventDict[kDCEventIdKey];
  self.name = eventDict[kDCEventNameKey];
  self.order = @([eventDict[kDCEventOrderKey] integerValue]);

  self.link = eventDict[kDCEventLinkKey];
  self.place = [eventDict[kDCEventPlaceKey] kv_decodeHTMLCharacterEntities];
  self.desctiptText =
      eventDict[kDCEventTextKey];  // kv_decodeHTMLCharacterEntities];
  self.timeRange = [DCTimeRange
      createManagedObjectInContext:
          self.managedObjectContext];  //(DCTimeRange*)[[DCMainProxy
  // sharedProxy]
  // createObjectOfClass:[DCTimeRange
  // class]];
  [self.timeRange setFrom:eventDict[kDCEventFromKey]
                       to:eventDict[kDCEventToKey]];

  [self addTypeForID:[eventDict[kDCEventTypeKey] intValue]];
  [self addSpeakersForIds:eventDict[kDCEventSpeakersKey]];
  [self addLevelForID:[eventDict[kDCEventExperienceLevelKey] intValue]];
  [self addTrackForId:[eventDict[kDCEventTrackKey] intValue]];
}

- (void)addTypeForID:(int)typeID {
  DCType* type = (DCType*)
      [[DCMainProxy sharedProxy] objectForID:typeID
                                     ofClass:[DCType class]
                                   inContext:self.managedObjectContext];
  if (!type) {
    type = [DCType createManagedObjectInContext:
                       self.managedObjectContext];  //(DCType*)[[DCMainProxy
    // sharedProxy]
    // createObjectOfClass:[DCType
    // class]];
    //        type = [[DCMainProxy sharedProxy] createType];
    type.name = @"noname";
    type.typeID = @(typeID);
  }
  [type addEventsObject:self];
}

- (void)addSpeakersForIds:(NSArray*)speakerIds {
  self.speakers = nil;
  for (NSNumber* speakerIdNum in speakerIds) {
    DCSpeaker* speaker = (DCSpeaker*)
        [[DCMainProxy sharedProxy] objectForID:[speakerIdNum intValue]
                                       ofClass:[DCSpeaker class]
                                     inContext:self.managedObjectContext];
    if (!speaker) {
      speaker =
          [DCSpeaker createManagedObjectInContext:self.managedObjectContext];
      speaker.speakerId = speakerIdNum;
      speaker.name = @"";
    }
    [speaker addEventsObject:self];
  }
}

- (void)addLevelForID:(int)levelID {
  DCLevel* level = (DCLevel*)
      [[DCMainProxy sharedProxy] objectForID:levelID
                                     ofClass:[DCLevel class]
                                   inContext:self.managedObjectContext];
  if (!level) {
    level = [DCLevel createManagedObjectInContext:self.managedObjectContext];
    level.levelId = @(levelID);
    level.name = @"";
    level.order = @(100);
    level.selectedInFilter = [NSNumber numberWithBool:YES];
  }
  [level addEventsObject:self];
}

- (void)addTrackForId:(int)trackId {
  DCTrack* track = (DCTrack*)
      [[DCMainProxy sharedProxy] objectForID:trackId
                                     ofClass:[DCTrack class]
                                   inContext:self.managedObjectContext];
  if (!track) {
    track = [DCTrack createManagedObjectInContext:self.managedObjectContext];
    track.trackId = @(trackId);
    track.name = @"";
    track.selectedInFilter = [NSNumber numberWithBool:YES];
  }
  [track addEventsObject:self];
}

- (UIImage*)imageForEvent {
  NSString* icon_name = nil;

  switch ([self.type.typeID integerValue]) {
    case DC_EVENT_24h:
      icon_name = @"ic_program_24_hour";
      break;

    case DC_EVENT_GROUP:
      icon_name = @"ic_program_group_photo";
      break;

    case DC_EVENT_SPEACH_OF_DAY:
      icon_name = @"ic_program_speach_of_the_day";
      break;

    case DC_EVENT_NONE:
    case DC_EVENT_SPEACH:
      icon_name = nil;
      break;

    case DC_EVENT_WALKING:
      icon_name = @"ic_program_walking_break";
      break;

    case DC_EVENT_LUNCH:
      icon_name = @"ic_program_lanch";
      break;

    case DC_EVENT_COFEE_BREAK:
      icon_name = @"ic_program_coffe_break";
      break;

    case DC_EVENT_REGISTRATION:
      icon_name = @"ic_program_check_in";
      break;

    default:
      break;
  }
  return icon_name ? [UIImage imageNamedFromBundle:icon_name] : nil;
}

- (NSDate*)startDate {
  return self.timeRange.from;
}

- (NSDate*)endDate {
  return self.timeRange.to;
}

+ (NSString*)idKey {
  return (NSString*)kDCEventIdKey;
}

@end
