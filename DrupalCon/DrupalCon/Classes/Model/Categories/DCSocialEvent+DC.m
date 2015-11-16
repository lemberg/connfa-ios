/**********************************************************************************
 *                                                                           
 *  The MIT License (MIT)
 *  Copyright (c) 2015 Lemberg Solutions Limited
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the 
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *   The above copyright notice and this permission notice shall be included in
 *   all  copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM,  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 *  IN THE SOFTWARE.
 *
 *                                                                           
 *****************************************************************************/



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
