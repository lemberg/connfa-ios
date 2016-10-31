
#import "DCMainEvent+DC.h"
#import "DCEvent+DC.h"
#import "NSManagedObject+DC.h"

#import "NSDate+DC.h"
#import "DCMainProxy.h"

@implementation DCMainEvent (DC)
#pragma mark - ManagedObjectUpdateProtocol

+ (void)updateFromDictionary:(NSDictionary*)events
                   inContext:(NSManagedObjectContext*)context;
{
  for (NSDictionary* day in events[kDCEventDaysKey]) {
    NSDate* date = [NSDate fabricateWithEventString:day[kDCEventDateKey]];
    for (NSDictionary* event in day[kDCEventsKey]) {
      int eventId = [event[kDCEventIdKey] intValue];
      DCMainEvent* mainEventInstance = (DCMainEvent*)
          [[DCMainProxy sharedProxy] objectForID:eventId

                                         ofClass:[DCMainEvent class]
                                       inContext:context];

      if (!mainEventInstance)  // create
          {
        mainEventInstance = [DCMainEvent createManagedObjectInContext:context];
        //(DCProgram*)[[DCMainProxy sharedProxy] createObjectOfClass:[DCProgram
        // class]];
      }

      if ([event[kDCParseObjectDeleted] intValue] == 1)  // remove
          {
        [[DCMainProxy sharedProxy] removeItem:mainEventInstance];

      } else  // update
          {
        [mainEventInstance updateFromDictionary:event forData:date];
      }
    }
  }
}

@end
