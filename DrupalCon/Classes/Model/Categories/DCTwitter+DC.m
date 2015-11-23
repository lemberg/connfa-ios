
#import "DCTwitter+DC.h"
#import "NSDictionary+DC.h"
#import "DCMainProxy.h"
#import "NSManagedObject+DC.h"

static NSString* kDCTwitterWidgetHTML = @"twitterWidgetHTML";

@implementation DCTwitter (DC)

+ (void)updateFromDictionary:(NSDictionary*)dictionary
                   inContext:(NSManagedObjectContext*)context {
  NSArray* twitters =
      [[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCTwitter class]
                                            inMainQueue:YES];
  DCTwitter* twitter;
  if (twitters.count == 0)  // create
  {
    twitter = [DCTwitter createManagedObjectInContext:context];
  } else {
    twitter = [twitters lastObject];
    if (twitters.count > 1) {
      NSLog(@"WARNING! Twitter widget not unique");
    }
  }

  twitter.widgetHTML = dictionary[kDCTwitterWidgetHTML];
}

@end
