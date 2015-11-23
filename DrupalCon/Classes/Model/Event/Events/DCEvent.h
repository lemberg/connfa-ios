
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCLevel, DCSpeaker, DCTimeRange, DCTrack, DCType;

@interface DCEvent : NSManagedObject

@property(nonatomic, retain) NSDate* date;
@property(nonatomic, retain) NSString* desctiptText;
@property(nonatomic, retain) NSNumber* eventId;
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* link;
@property(nonatomic, retain) NSString* place;
@property(nonatomic, retain) NSNumber* order;
@property(nonatomic, retain) DCLevel* level;
@property(nonatomic, retain) NSSet* speakers;
@property(nonatomic, retain) DCTimeRange* timeRange;
@property(nonatomic, retain) NSSet* tracks;
@property(nonatomic, retain) DCType* type;

@property(nonatomic, retain) NSNumber* favorite;
@property(nonatomic, retain) NSString* calendarId;

@end

@interface DCEvent (CoreDataGeneratedAccessors)

- (void)addSpeakersObject:(DCSpeaker*)value;
- (void)removeSpeakersObject:(DCSpeaker*)value;
- (void)addSpeakers:(NSSet*)values;
- (void)removeSpeakers:(NSSet*)values;

- (void)addTracksObject:(DCTrack*)value;
- (void)removeTracksObject:(DCTrack*)value;
- (void)addTracks:(NSSet*)values;
- (void)removeTracks:(NSSet*)values;

@end
