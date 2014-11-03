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

#import "DCLevel+DC.h"
#import "DCMainProxy.h"
#import "NSDictionary+DC.h"
#import "NSManagedObject+DC.h"

NSString * kDCLevel_levels_key = @"levels";
NSString * kDCLevel_levelID_key = @"levelID";
NSString * kDCLevel_levelName_key = @"levelName";
NSString * kDCLevel_levelOrder_key = @"levelOrder";

@implementation DCLevel (DC)

#pragma mark - ManagedObjectUpdateProtocol

+ (void)updateFromDictionary:(NSDictionary *)levels inContext:(NSManagedObjectContext *)context
{
    //adding
    for (NSDictionary * dictionary in levels[kDCLevel_levels_key])
    {
        DCLevel * level = (DCLevel*)[[DCMainProxy sharedProxy] objectForID:[dictionary[kDCLevel_levelID_key] intValue]
                                                                   ofClass:[DCLevel class]
                                                                 inContext:context];
        
        if (!level) // then create
        {
            level = [DCLevel createManagedObjectInContext:context];//(DCLevel*)[[DCMainProxy sharedProxy] createObjectOfClass:[DCLevel class]];
        }
        
        if ([dictionary[kDCParseObjectDeleted] intValue]==1) // remove
        {
            [[DCMainProxy sharedProxy] removeItem:level];
        }
        else // update
        {
            level.levelId = dictionary[kDCLevel_levelID_key];
            level.name = dictionary[kDCLevel_levelName_key];
            level.order = @([dictionary[kDCLevel_levelOrder_key] integerValue]);
        }
    }

}


+ (NSString*)idKey
{
    return (NSString*)kDCLevel_levelID_key;
}

@end
