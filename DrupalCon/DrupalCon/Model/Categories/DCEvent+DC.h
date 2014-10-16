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

#import "DCEvent.h"
#import "DCParseProtocol.h"
#import "NSDictionary+DC.h"

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

@interface DCEvent (DC) <parseProtocol>

- (NSInteger)getTypeID;
- (NSArray*)speakersNames;

+ (void)parseEventFromDictionaty:(NSDictionary*)eventDict toObject:(DCEvent*)object forDate:(NSDate*)date;

- (void)addTypeForID:(NSInteger)typeID;
- (void)addSpeakersForIds:(NSArray*)speakerIds;
- (void)addLevelForID:(NSInteger)levelID;
- (void)addTrackForId:(NSInteger)trackId;

- (UIImage*)imageForEvent;

@end
