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

@interface DCEvent (DC)

- (NSInteger)getTypeID;
- (NSArray*)speakersNames;

@end
