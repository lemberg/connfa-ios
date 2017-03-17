
#import "DCInfoCategory+DC.h"

const NSString* kDCInfoCategoryId = @"infoId";
const NSString* kDCInfoCategoryTitle = @"infoTitle";
const NSString* kDCInfoCategoryHTML = @"html";

@implementation DCInfoCategory (DC)

+ (void)updateFromDictionary:(NSDictionary*)dictionary
                   inContext:(NSManagedObjectContext*)context {
}

+ (NSString*)idKey {
  return (NSString*)kDCInfoCategoryId;
}

@end
