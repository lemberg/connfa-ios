
#import "DCLocation+DC.h"
#import "NSDictionary+DC.h"
#import "DCMainProxy.h"
#import "NSManagedObject+DC.h"

NSString* kDCLocationsKey = @"locations";
NSString* kDCLocationIdKey = @"locationId";
NSString* kDCLocationLongitudeKey = @"longitude";
NSString* kDCLocationLatitudeKey = @"latitude";
NSString* kDCLocationPlaceNameKey = @"locationName";
NSString* kDCLocationAddressKey = @"address";

@implementation DCLocation (DC)

#pragma mark - ManagedObjectUpdateProtocol

+ (void)updateFromDictionary:(NSDictionary*)location
                   inContext:(NSManagedObjectContext*)context {
  // adding
  for (NSDictionary* dictionary in location[kDCLocationsKey]) {
    DCLocation* location = (DCLocation*)[[DCMainProxy sharedProxy]
        objectForID:[dictionary[kDCLocationIdKey] intValue]
            ofClass:[DCLocation class]
          inContext:context];

    if (!location)  // then create
    {
      location = [DCLocation createManagedObjectInContext:context];
    }

    if ([dictionary[kDCParseObjectDeleted] intValue] == 1)  // remove
    {
      [[DCMainProxy sharedProxy] removeItem:location];
    } else  // update
    {
      location.locationId = dictionary[kDCLocationIdKey];
      location.latitude = dictionary[kDCLocationLatitudeKey];
      location.longitude = dictionary[kDCLocationLongitudeKey];
      location.name = dictionary[kDCLocationPlaceNameKey];
      location.address = dictionary[kDCLocationAddressKey];
      location.order = [NSNumber
          numberWithFloat:[dictionary[kDCParseObjectOrderKey] floatValue]];
    }
  }
}

+ (NSString*)idKey {
  return (NSString*)kDCLocationIdKey;
}

@end
