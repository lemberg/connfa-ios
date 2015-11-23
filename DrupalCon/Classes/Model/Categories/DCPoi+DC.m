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
