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



#import "DCInfo+DC.h"
#import "NSDictionary+DC.h"
#import "DCMainProxy.h"
#import "NSManagedObject+DC.h"
#import "DCInfoCategory+DC.h"

static NSString* kDCInfoTitle = @"title";
static NSString* kDCInfoCategories = @"info";

static NSString* kDCInfoTitleMajor = @"titleMajor";
static NSString* kDCInfoTitleMinor = @"titleMinor";

@implementation DCInfo (DC)

#pragma mark - ManagedObjectUpdateProtocol

+ (void)updateFromDictionary:(NSDictionary*)dictionary
                   inContext:(NSManagedObjectContext*)context {
  NSArray* infos =
      [[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCInfo class]
                                              inContext:context];
  DCInfo* info;
  if (infos.count == 0) {
    info = [DCInfo createManagedObjectInContext:context];
  } else if (infos.count > 1)  // There should be one info instance only.
  {
    NSLog(@"WARNING! info is not unique");
    info = [infos lastObject];
  } else {
    info = [infos lastObject];
  }

  if ([[dictionary allKeys] containsObject:kDCInfoTitle]) {
    info.titleMajor = dictionary[kDCInfoTitle][kDCInfoTitleMajor];
    info.titleMinor = dictionary[kDCInfoTitle][kDCInfoTitleMinor];
  }

  if ([[dictionary allKeys] containsObject:kDCInfoCategories]) {
    for (NSDictionary* infoCategory in(NSArray*)dictionary[kDCInfoCategories]) {
#warning figueout if it is corrent to use add for updating
      DCInfoCategory* category =
          [DCInfo DC_parseInfoCategoriesFromDictionary:infoCategory
                                             inContext:context];
      if (category)
        category.info = info;
    }
  }
}

#pragma mark -

+ (DCInfoCategory*)
DC_parseInfoCategoriesFromDictionary:(NSDictionary*)categoryDict
                           inContext:(NSManagedObjectContext*)context {
  DCInfoCategory* category = (DCInfoCategory*)[[DCMainProxy sharedProxy]
      objectForID:[categoryDict[kDCInfoCategoryId] intValue]
          ofClass:[DCInfoCategory class]
        inContext:context];
  if (!category) {
    category = [DCInfoCategory createManagedObjectInContext:context];
  }

  if ([categoryDict[kDCParseObjectDeleted] intValue] == 1)  // remove
  {
    [[DCMainProxy sharedProxy] removeItem:category];
    return nil;
  } else  // update
  {
    category.infoId = categoryDict[kDCInfoCategoryId];
    category.name = categoryDict[kDCInfoCategoryTitle];
    category.html = categoryDict[kDCInfoCategoryHTML];
    category.order = [NSNumber
        numberWithFloat:[categoryDict[kDCParseObjectOrderKey] floatValue]];
  }
  return category;
}

@end
