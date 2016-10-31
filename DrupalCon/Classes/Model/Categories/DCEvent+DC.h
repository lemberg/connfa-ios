
#import "DCEvent.h"
#import "DCManagedObjectUpdateProtocol.h"

#import "NSDictionary+DC.h"

extern NSString* kDCEventsKey;
extern NSString* kDCEventDaysKey;
extern NSString* kDCEventDateKey;
extern NSString* kDCEventFromKey;
extern NSString* kDCEventToKey;
extern NSString* kDCEventTypeKey;
extern NSString* kDCEventNameKey;
extern NSString* kDCEventLinkKey;
extern NSString* kDCEventSpeakersKey;
extern NSString* kDCEventTrackKey;
extern NSString* kDCEventExperienceLevelKey;
extern NSString* kDCEventIdKey;
extern NSString* kDCEventTextKey;
extern NSString* kDCEventPlaceKey;
extern NSString* kDCEventOrderKey;

typedef NS_ENUM(int, DCEventType) {
  DC_EVENT_NONE = 0,
  DC_EVENT_SPEACH = 1,
  DC_EVENT_SPEACH_OF_DAY = 2,
  DC_EVENT_COFEE_BREAK = 3,
  DC_EVENT_LUNCH = 4,
  DC_EVENT_24h = 5,
  DC_EVENT_GROUP = 6,
  DC_EVENT_WALKING = 7,
  DC_EVENT_REGISTRATION = 8,
  DC_EVENT_FREE_SLOT = 9
};

@interface DCEvent (DC)<ManagedObjectUpdateProtocol>

- (NSInteger)getTypeID;
- (NSArray*)speakersNames;

+ (void)updateFromDictionary:(NSDictionary*)dictionary
                   inContext:(NSManagedObjectContext*)context;
- (void)updateFromDictionary:(NSDictionary*)eventDict forData:(NSDate*)date;

- (void)addTypeForID:(int)typeID;
- (void)addSpeakersForIds:(NSArray*)speakerIds;
- (void)addLevelForID:(int)levelID;
- (void)addTrackForId:(int)trackId;

- (UIImage*)imageForEvent;

- (NSDate*)startDate;
- (NSDate*)endDate;

@end
