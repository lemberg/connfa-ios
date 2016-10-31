
#import "DCBof+DC.h"
#import "DCEvent+DC.h"
#import "NSManagedObject+DC.h"
#import "NSDate+DC.h"
#import "DCMainProxy.h"
#import "NSDictionary+DC.h"

@implementation DCBof (DC)

#pragma mark - ManagedObjectUpdateProtocol

+ (void)updateFromDictionary:(NSDictionary*)events
                   inContext:(NSManagedObjectContext*)context;
{
  for (NSDictionary* day in events[kDCEventDaysKey]) {
    NSDate* date = [NSDate fabricateWithEventString:day[kDCEventDateKey]];
    for (NSDictionary* event in day[kDCEventsKey]) {
      DCBof* bofInstance = (DCBof*)
          [[DCMainProxy sharedProxy] objectForID:[event[kDCEventIdKey] intValue]
                                         ofClass:[DCBof class]
                                       inContext:context];

      if (!bofInstance)  // create
          {
        bofInstance = [DCBof createManagedObjectInContext:context];
      }
      if ([event[kDCParseObjectDeleted] intValue] == 1)  // remove
          {
        [[DCMainProxy sharedProxy] removeItem:bofInstance];

      } else  // update
          {
        [bofInstance
            updateFromDictionary:event
                         forData:date];  // DCBof parseEventFromDictionaty:event
                                         // toObject:bofInstance forDate:date];
      }
    }
  }
}

@end
