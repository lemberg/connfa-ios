
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCEvent;

@interface DCLevel : NSManagedObject

@property(nonatomic, retain) NSNumber* levelId;
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSNumber* order;
@property(nonatomic, retain) NSNumber* selectedInFilter;
@property(nonatomic, retain) NSSet* events;
@end

@interface DCLevel (CoreDataGeneratedAccessors)

- (void)addEventsObject:(DCEvent*)value;
- (void)removeEventsObject:(DCEvent*)value;
- (void)addEvents:(NSSet*)values;
- (void)removeEvents:(NSSet*)values;

@end
