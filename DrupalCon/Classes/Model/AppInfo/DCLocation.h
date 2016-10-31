
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DCLocation : NSManagedObject

@property(nonatomic, retain) NSString* latitude;
@property(nonatomic, retain) NSString* longitude;
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* address;
@property(nonatomic, retain) NSNumber* locationId;
@property(nonatomic, retain) NSNumber* order;

@end
