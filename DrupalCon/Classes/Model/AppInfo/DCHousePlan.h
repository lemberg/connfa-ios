
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DCHousePlan : NSManagedObject

@property(nonatomic, retain) NSNumber* housePlanId;
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* imageURL;
@property(nonatomic, retain) NSNumber* order;

@end
