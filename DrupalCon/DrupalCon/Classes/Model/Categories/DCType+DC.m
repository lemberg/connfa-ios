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
