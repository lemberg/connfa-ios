
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCEvent;

@interface DCType : NSManagedObject

@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* typeIcon;
@property(nonatomic, retain) NSNumber* typeID;
@property(nonatomic, retain) NSNumber* order;
@property(nonatomic, retain) NSSet* events;
@end

@interface DCType (CoreDataGeneratedAccessors)

- (void)addEventsObject:(DCEvent*)value;
- (void)removeEventsObject:(DCEvent*)value;
- (void)addEvents:(NSSet*)values;
- (void)removeEvents:(NSSet*)values;

@end
