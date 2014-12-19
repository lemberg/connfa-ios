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
#import "DCManagedObjectUpdateProtocol.h"

#import "NSDictionary+DC.h"

extern NSString * kDCEventsKey;
extern NSString * kDCEventDaysKey;
extern NSString * kDCEventDateKey;
extern NSString * kDCEventFromKey;
extern NSString * kDCEventToKey;
extern NSString * kDCEventTypeKey;
extern NSString * kDCEventNameKey;
extern NSString * kDCEventSpeakersKey;
extern NSString * kDCEventTrackKey;
extern NSString * kDCEventExperienceLevelKey;
extern NSString * kDCEventIdKey;
extern NSString * kDCEventTextKey;
extern NSString * kDCEventPlaceKey;

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

@interface DCEvent (DC) <ManagedObjectUpdateProtocol>

- (NSInteger)getTypeID;
- (NSArray*)speakersNames;


+ (void)updateFromDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;
- (void)updateFromDictionary:(NSDictionary *)eventDict forData:(NSDate *)date;


- (void)addTypeForID:(int)typeID;
- (void)addSpeakersForIds:(NSArray*)speakerIds;
- (void)addLevelForID:(int)levelID;
- (void)addTrackForId:(int)trackId;

- (UIImage*)imageForEvent;

@end
