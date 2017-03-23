
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DCAppSettings : NSManagedObject
// Seconds GMT offset
@property(nonatomic, retain) NSString* timeZoneName;
@property(nonatomic, retain) NSString* widgetHTML;
@property(nonatomic, retain) NSString* searchQuery;

@end
