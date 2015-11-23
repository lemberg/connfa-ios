
#import "DCLevel+DC.h"
#import "DCMainProxy.h"
#import "NSDictionary+DC.h"
#import "NSManagedObject+DC.h"

NSString* kDCLevelsKey = @"levels";
NSString* kDCLevelIdKey = @"levelId";
NSString* kDCLevelNameKey = @"levelName";
NSString* kDCLevelSelectedInFilterKey = @"levelSelectedInFilter";

@implementation DCLevel (DC)

#pragma mark - ManagedObjectUpdateProtocol

+ (void)updateFromDictionary:(NSDictionary*)levels
                   inContext:(NSManagedObjectContext*)context {
  // adding
  for (NSDictionary* dictionary in levels[kDCLevelsKey]) {
    DCLevel* level = (DCLevel*)[[DCMainProxy sharedProxy]
        objectForID:[dictionary[kDCLevelIdKey] intValue]
            ofClass:[DCLevel class]
          inContext:context];

    if (!level)  // then create
    {
      level = [DCLevel
          createManagedObjectInContext:context];  //(DCLevel*)[[DCMainProxy
      // sharedProxy]
      // createObjectOfClass:[DCLevel
      // class]];
      level.selectedInFilter = [NSNumber numberWithBool:YES];
    }

    if ([dictionary[kDCParseObjectDeleted] intValue] == 1)  // remove
    {
      [[DCMainProxy sharedProxy] removeItem:level];
    } else  // update
    {
      level.levelId = dictionary[kDCLevelIdKey];
      level.name = dictionary[kDCLevelNameKey];
      level.order = [NSNumber
          numberWithFloat:[dictionary[kDCParseObjectOrderKey] floatValue]];
    }
  }
}

+ (NSString*)idKey {
  return (NSString*)kDCLevelIdKey;
}

@end
