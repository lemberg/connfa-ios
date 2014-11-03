//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DCType+DC.h"
#import "DCMainProxy.h"
#import "NSDictionary+DC.h"
#import "NSManagedObject+DC.h"

const NSString * kDCType_types_key = @"types";
const NSString * kDCType_typeID_key = @"typeID";
const NSString * kDCType_typeName_key = @"typeName";

@implementation DCType (DC)


#pragma mark - Update protocol method
+ (void)updateFromDictionary:(NSDictionary *)types inContext:(NSManagedObjectContext *)context
{
    //adding
    for (NSDictionary * dictionary in types[kDCType_types_key])
    {
        DCType * type = (DCType*)[[DCMainProxy sharedProxy] objectForID:[dictionary[kDCType_typeID_key] intValue] ofClass:[DCType class] inContext:context];
        
        if (!type) // then create
        {
            type = [DCType createManagedObjectInContext:context];
        }
        
        if ([dictionary[kDCParseObjectDeleted] intValue]==1) // remove
        {
            [[DCMainProxy sharedProxy] removeItem:type];
        }
        else // update
        {
            type.typeID = dictionary[kDCType_typeID_key];
            type.name = dictionary[kDCType_typeName_key];
        }
    }
}

#pragma mark - parce protocol


+ (NSString*)idKey
{
    return (NSString*)kDCType_typeID_key;
}

@end
