
#import "DCType+DC.h"
#import "DCMainProxy.h"
#import "NSDictionary+DC.h"
#import "NSManagedObject+DC.h"

const NSString* kDCTypesKey = @"types";
const NSString* kDCTypeIdKey = @"typeID";
const NSString* kDCTypeNameKey = @"typeName";
const NSString* kDCTypeIconURLKey = @"typeIconURL";

@implementation DCType (DC)

#pragma mark - Update protocol method
+ (void)updateFromDictionary:(NSDictionary*)types
                   inContext:(NSManagedObjectContext*)context {
  // adding
  for (NSDictionary* dictionary in types[kDCTypesKey]) {
    DCType* type = (DCType*)[[DCMainProxy sharedProxy]
        objectForID:[dictionary[kDCTypeIdKey] intValue]
            ofClass:[DCType class]
          inContext:context];

    if (!type)  // then create
    {
      type = [DCType createManagedObjectInContext:context];
    }

    if ([dictionary[kDCParseObjectDeleted] intValue] == 1)  // remove
    {
      [[DCMainProxy sharedProxy] removeItem:type];
    } else  // update
    {
      type.typeID = dictionary[kDCTypeIdKey];
      type.name = dictionary[kDCTypeNameKey];
      type.order = [NSNumber
          numberWithFloat:[dictionary[kDCParseObjectOrderKey] floatValue]];
      type.typeIcon = dictionary[kDCTypeIconURLKey];
    }
  }
}

#pragma mark - parce protocol

+ (NSString*)idKey {
  return (NSString*)kDCTypeIdKey;
}

@end
