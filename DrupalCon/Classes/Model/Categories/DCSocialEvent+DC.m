
#import "DCSocialEvent+DC.h"
#import "DCEvent+DC.h"
#import "NSManagedObject+DC.h"

#import "NSDate+DC.h"
#import "DCMainProxy.h"

@implementation DCSocialEvent (DC)
#pragma mark - ManagedObjectUpdateProtocol

+ (void)updateFromDictionary:(NSDictionary*)events
                   inContext:(NSManagedObjectContext*)context;
{
  for (NSDictionary* day in events[kDCEventDaysKey]) {
    NSDate* date = [NSDate fabricateWithEventString:day[kDCEventDateKey]];
    for (NSDictionary* event in day[kDCEventsKey]) {
      DCSocialEvent* socialEventInstance = (DCSocialEvent*)
          [[DCMainProxy sharedProxy] objectForID:[event[kDCEventIdKey] intValue]
                                         ofClass:[DCSocialEvent class]
                                       inContext:context];

      if (!socialEventInstance)  // create
          {
        socialEventInstance =
            [DCSocialEvent createManagedObjectInContext:context];
      }

      if ([event[kDCParseObjectDeleted] intValue] == 1)  // remove
          {
        [[DCMainProxy sharedProxy] removeItem:socialEventInstance];

      } else  // update
          {
        [socialEventInstance updateFromDictionary:event forData:date];
      }
    }
  }
}

@end
