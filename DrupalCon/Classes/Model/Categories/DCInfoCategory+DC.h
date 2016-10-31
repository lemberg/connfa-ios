
#import "DCInfoCategory.h"
#import "DCManagedObjectUpdateProtocol.h"

extern NSString* kDCInfoCategoryId;
extern NSString* kDCInfoCategoryTitle;
extern NSString* kDCInfoCategoryHTML;

@interface DCInfoCategory (DC)<ManagedObjectUpdateProtocol>

@end
