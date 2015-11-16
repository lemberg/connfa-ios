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



#import "DCAppSettings+DC.h"
#import "NSManagedObject+DC.h"

@implementation DCAppSettings (DC)
static NSString* kDCAppSettingsTimeZoneValue = @"timezone";
static NSString* kDCAppSettings = @"settings";

+ (void)updateFromDictionary:(NSDictionary*)dictionary
                   inContext:(NSManagedObjectContext*)context {
  NSArray* settings =
      [[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCAppSettings class]
                                              inContext:context];
  DCAppSettings* appSettings;
  if (settings.count == 0) {
    appSettings = [DCAppSettings createManagedObjectInContext:context];
  } else if (settings.count > 1)  // There should be one info instance only.
  {
    NSLog(@"WARNING! info is not unique");
    appSettings = [settings lastObject];
  } else {
    appSettings = [settings lastObject];
  }

  if ([[dictionary allKeys] containsObject:kDCAppSettings]) {
    appSettings.eventTimeZone = @(
        [dictionary[kDCAppSettings][kDCAppSettingsTimeZoneValue] integerValue]);
  }
}
@end
