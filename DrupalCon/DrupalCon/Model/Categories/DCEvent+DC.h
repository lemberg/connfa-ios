//
//  DCEvent+DC.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCEvent.h"

extern NSString * kDCEvent_days_key;
extern NSString * kDCEvent_date_key;
extern NSString * kDCEvent_from_key;
extern NSString * kDCEvent_to_key;
extern NSString * kDCEvent_type_key;
extern NSString * kDCEvent_name_key;
extern NSString * kDCEvent_speakers_key;
extern NSString * kDCEvent_track_key;
extern NSString * kDCEvent_experienceLevel_key;
extern NSString * kDCEvent_eventId_key;
extern NSString * kDCEvent_text_key;
extern NSString * kDCEvent_place_key;

typedef NS_ENUM (int, DCEventType) {
    DC_EVENT_NONE = 0,
    DC_EVENT_SPEACH = 1,
    DC_EVENT_SPEACH_OF_DAY = 2,
    DC_EVENT_COFEE_BREAK = 3,
    DC_EVENT_LUNCH = 4,
    DC_EVENT_24h = 5,
    DC_EVENT_GROUP = 6,
    DC_EVENT_WALKING = 7,
    DC_EVENT_REGISTRATION = 8
};

@interface DCEvent (DC)

- (NSInteger)getTypeID;
- (NSArray*)speakersNames;

+ (void)parseEventFromDictionaty:(NSDictionary*)eventDict toObject:(DCEvent*)object forDate:(NSDate*)date;
+ (void)parseFromJSONData:(NSData*)jsonData;

- (void)addTypeForID:(NSInteger)typeID;
- (void)addSpeakersForIds:(NSArray*)speakerIds;
- (void)addLevelForID:(NSInteger)levelID;
- (void)addTrackForId:(NSInteger)trackId;

- (UIImage*)imageForEvent;

@end
