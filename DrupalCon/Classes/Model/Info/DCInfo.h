
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCInfoCategory;

@interface DCInfo : NSManagedObject

@property(nonatomic, retain) NSString* titleMajor;
@property(nonatomic, retain) NSString* titleMinor;
@property(nonatomic, retain) NSSet* infoCategory;
@end

@interface DCInfo (CoreDataGeneratedAccessors)

- (void)addInfoCategoryObject:(DCInfoCategory*)value;
- (void)removeInfoCategoryObject:(DCInfoCategory*)value;
- (void)addInfoCategory:(NSSet*)values;
- (void)removeInfoCategory:(NSSet*)values;

@end
