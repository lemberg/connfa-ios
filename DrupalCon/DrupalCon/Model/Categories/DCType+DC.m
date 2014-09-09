//
//  DCType+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCType+DC.h"
#import "DCMainProxy.h"
#import "NSDictionary+DC.h"

const NSString * kDCType_types_key = @"types";
const NSString * kDCType_typeID_key = @"typeID";
const NSString * kDCType_typeName_key = @"typeName";

@implementation DCType (DC)

+ (void)parceFromJsonData:(NSData *)jsonData
{
    NSError * err = nil;
    NSDictionary * types = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:kNilOptions
                                                                  error:&err];
    types = [types dictionaryByReplacingNullsWithStrings];

    if (err)
    {
        NSLog(@"WRONG! json");
        return;
    }
    
    for (NSDictionary * typeDictionary in types[kDCType_types_key])
    {
        DCType * type = [[DCMainProxy sharedProxy] createType];
        type.typeID = typeDictionary[kDCType_typeID_key];
        type.name = typeDictionary[kDCType_typeName_key];
    }
}

@end
