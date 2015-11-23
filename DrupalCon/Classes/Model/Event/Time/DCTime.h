
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DCTime : NSManagedObject

@property(nonatomic, retain) NSNumber* hour;
@property(nonatomic, retain) NSNumber* minute;

@end
