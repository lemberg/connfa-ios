
#import "DCHousePlan+DC.h"
#import "NSDictionary+DC.h"
#import "DCMainProxy.h"
#import "NSManagedObject+DC.h"

static NSString* kDCHousePlansKey = @"floorPlans";
static NSString* kDCHousePlanIdKey = @"floorPlanId";
static NSString* kDCHousePlanNameKey = @"floorPlanName";
static NSString* kDCHousePlanImageURLKey = @"floorPlanImageURL";
static NSString* kDCHouseEntityPlanIdKey = @"housePlanId";

@implementation DCHousePlan (DC)

#pragma mark - ManagedObjectUpdateProtocol

+ (void)updateFromDictionary:(NSDictionary*)housePlans
                   inContext:(NSManagedObjectContext*)context {
  // adding
  for (NSDictionary* dictionary in housePlans[kDCHousePlansKey]) {
    DCHousePlan* housePlan = (DCHousePlan*)[[DCMainProxy sharedProxy]
        objectForID:[dictionary[kDCHousePlanIdKey] intValue]
            ofClass:[DCHousePlan class]
          inContext:context];

    if (!housePlan)  // then create
    {
      housePlan = [DCHousePlan createManagedObjectInContext:context];
    }

    if ([dictionary[kDCParseObjectDeleted] intValue] == 1)  // remove
    {
      [[DCMainProxy sharedProxy] removeItem:housePlan];
    } else  // update
    {
      housePlan.housePlanId = dictionary[kDCHousePlanIdKey];
      housePlan.name = dictionary[kDCHousePlanNameKey];
      housePlan.imageURL = dictionary[kDCHousePlanImageURLKey];
      housePlan.order = [NSNumber
          numberWithFloat:[dictionary[kDCParseObjectOrderKey] floatValue]];
    }
  }
}

+ (NSString*)idKey {
  return (NSString*)kDCHouseEntityPlanIdKey;
}

@end
