
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DCPoi : NSManagedObject

@property(nonatomic, retain) NSNumber* poiId;
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* descript;
@property(nonatomic, retain) NSString* imageURL;
@property(nonatomic, retain) NSString* detailURL;
@property(nonatomic, retain) NSNumber* order;

@end
