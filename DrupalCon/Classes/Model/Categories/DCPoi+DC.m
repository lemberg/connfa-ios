
#import "DCPoi+DC.h"
#import "NSDictionary+DC.h"
#import "DCMainProxy.h"
#import "NSManagedObject+DC.h"

static NSString* kDCPoisKey = @"poi";
static NSString* kDCPoiIdKey = @"poiId";
static NSString* kDCPoiNameKey = @"poiName";
static NSString* kDCPoiDetailURLKey = @"poiDetailURL";
static NSString* kDCPoiDescription = @"poiDescription";
static NSString* kDCPoiImageURLKey = @"poiImageURL";

@implementation DCPoi (DC)

#pragma mark - ManagedObjectUpdateProtocol

+ (void)updateFromDictionary:(NSDictionary*)pois
                   inContext:(NSManagedObjectContext*)context {
  // adding
  for (NSDictionary* dictionary in pois[kDCPoisKey]) {
    DCPoi* poi = (DCPoi*)[[DCMainProxy sharedProxy]
        objectForID:[dictionary[kDCPoiIdKey] intValue]
            ofClass:[DCPoi class]
          inContext:context];

    if (!poi)  // then create
    {
      poi = [DCPoi createManagedObjectInContext:context];
    }

    if ([dictionary[kDCParseObjectDeleted] intValue] == 1)  // remove
    {
      [[DCMainProxy sharedProxy] removeItem:poi];
    } else  // update
    {
      poi.poiId = dictionary[kDCPoiIdKey];
      poi.name = dictionary[kDCPoiNameKey];
      poi.descript = dictionary[kDCPoiDescription];
      poi.imageURL = dictionary[kDCPoiImageURLKey];
      poi.detailURL = dictionary[kDCPoiDetailURLKey];
      poi.order = [NSNumber
          numberWithFloat:[dictionary[kDCParseObjectOrderKey] floatValue]];
    }
  }
}

+ (NSString*)idKey {
  return (NSString*)kDCPoiIdKey;
}

@end
