//
//  DCEvent+CoreDataProperties.h
//  Connfa
//
//  Created by Oleh Kurnenkov on 5/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCEvent+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCEvent (CoreDataProperties)

+ (NSFetchRequest<DCEvent *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *calendarId;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *desctiptText;
@property (nullable, nonatomic, copy) NSNumber *eventId;
@property (nullable, nonatomic, copy) NSNumber *favorite;
@property (nullable, nonatomic, copy) NSString *link;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *order;
@property (nullable, nonatomic, copy) NSString *place;
@property (nullable, nonatomic, retain) DCLevel *level;
@property (nullable, nonatomic, retain) NSSet<DCSharedSchedule *> *schedules;
@property (nullable, nonatomic, retain) NSSet<DCSpeaker *> *speakers;
@property (nullable, nonatomic, retain) DCTimeRange *timeRange;
@property (nullable, nonatomic, retain) NSSet<DCTrack *> *tracks;
@property (nullable, nonatomic, retain) DCType *type;

@end

@interface DCEvent (CoreDataGeneratedAccessors)

- (void)addSchedulesObject:(DCSharedSchedule *)value;
- (void)removeSchedulesObject:(DCSharedSchedule *)value;
- (void)addSchedules:(NSSet<DCSharedSchedule *> *)values;
- (void)removeSchedules:(NSSet<DCSharedSchedule *> *)values;

- (void)addSpeakersObject:(DCSpeaker *)value;
- (void)removeSpeakersObject:(DCSpeaker *)value;
- (void)addSpeakers:(NSSet<DCSpeaker *> *)values;
- (void)removeSpeakers:(NSSet<DCSpeaker *> *)values;

- (void)addTracksObject:(DCTrack *)value;
- (void)removeTracksObject:(DCTrack *)value;
- (void)addTracks:(NSSet<DCTrack *> *)values;
- (void)removeTracks:(NSSet<DCTrack *> *)values;

@end

NS_ASSUME_NONNULL_END
