
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCTime;

@interface DCTimeRange : NSManagedObject

@property(nonatomic, retain) NSDate* from;
@property(nonatomic, retain) NSDate* to;

@end
