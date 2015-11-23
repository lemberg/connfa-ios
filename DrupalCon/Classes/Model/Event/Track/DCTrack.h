
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCEvent;

@interface DCTrack : NSManagedObject

@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSNumber* trackId;
@property(nonatomic, retain) NSNumber* order;
@property(nonatomic, retain) NSNumber* selectedInFilter;
@property(nonatomic, retain) NSSet* events;
@end

@interface DCTrack (CoreDataGeneratedAccessors)

- (void)addEventsObject:(DCEvent*)value;
- (void)removeEventsObject:(DCEvent*)value;
- (void)addEvents:(NSSet*)values;
- (void)removeEvents:(NSSet*)values;

@end
