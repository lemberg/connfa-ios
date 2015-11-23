
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCInfo;

@interface DCInfoCategory : NSManagedObject

@property(nonatomic, retain) NSString* html;
@property(nonatomic, retain) NSNumber* infoId;
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSNumber* order;
@property(nonatomic, retain) DCInfo* info;

@end
