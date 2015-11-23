
#import "DCInfo+DC.h"
#import "NSDictionary+DC.h"
#import "DCMainProxy.h"
#import "NSManagedObject+DC.h"
#import "DCInfoCategory+DC.h"

static NSString* kDCInfoTitle = @"title";
static NSString* kDCInfoCategories = @"info";

static NSString* kDCInfoTitleMajor = @"titleMajor";
static NSString* kDCInfoTitleMinor = @"titleMinor";

@implementation DCInfo (DC)

#pragma mark - ManagedObjectUpdateProtocol

+ (void)updateFromDictionary:(NSDictionary*)dictionary
                   inContext:(NSManagedObjectContext*)context {
  NSArray* infos =
      [[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCInfo class]
                                              inContext:context];
  DCInfo* info;
  if (infos.count == 0) {
    info = [DCInfo createManagedObjectInContext:context];
  } else if (infos.count > 1)  // There should be one info instance only.
  {
    NSLog(@"WARNING! info is not unique");
    info = [infos lastObject];
  } else {
    info = [infos lastObject];
  }

  if ([[dictionary allKeys] containsObject:kDCInfoTitle]) {
    info.titleMajor = dictionary[kDCInfoTitle][kDCInfoTitleMajor];
    info.titleMinor = dictionary[kDCInfoTitle][kDCInfoTitleMinor];
  }

  if ([[dictionary allKeys] containsObject:kDCInfoCategories]) {
    for (NSDictionary* infoCategory in(NSArray*)dictionary[kDCInfoCategories]) {
      DCInfoCategory* category =
          [DCInfo DC_parseInfoCategoriesFromDictionary:infoCategory
                                             inContext:context];
      if (category)
        category.info = info;
    }
  }
}

#pragma mark -

+ (DCInfoCategory*)
DC_parseInfoCategoriesFromDictionary:(NSDictionary*)categoryDict
                           inContext:(NSManagedObjectContext*)context {
  DCInfoCategory* category = (DCInfoCategory*)[[DCMainProxy sharedProxy]
      objectForID:[categoryDict[kDCInfoCategoryId] intValue]
          ofClass:[DCInfoCategory class]
        inContext:context];
  if (!category) {
    category = [DCInfoCategory createManagedObjectInContext:context];
  }

  if ([categoryDict[kDCParseObjectDeleted] intValue] == 1)  // remove
  {
    [[DCMainProxy sharedProxy] removeItem:category];
    return nil;
  } else  // update
  {
    category.infoId = categoryDict[kDCInfoCategoryId];
    category.name = categoryDict[kDCInfoCategoryTitle];
    category.html = categoryDict[kDCInfoCategoryHTML];
    category.order = [NSNumber
        numberWithFloat:[categoryDict[kDCParseObjectOrderKey] floatValue]];
  }
  return category;
}

@end
