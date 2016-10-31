
#import <CoreData/CoreData.h>

@interface NSManagedObject (DC)

+ (instancetype)createManagedObjectInContext:(NSManagedObjectContext*)context;

@end
