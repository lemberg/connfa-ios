//
//  DCLevel+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCLevel+DC.h"
#import "DCMainProxy.h"

NSString * kDCLevel_levels_key = @"levels";
NSString * kDCLevel_levelID_key = @"levelID";
NSString * kDCLevel_levelName_key = @"levelName";
NSString * kDCLevel_levelOrder_key = @"levelOrder";

@implementation DCLevel (DC)

+ (void)parceFromJsonData:(NSData *)jsonData
{
    NSError * err = nil;
    NSDictionary * levels = [NSJSONSerialization JSONObjectWithData:jsonData
                                                              options:kNilOptions
                                                                error:&err];
    if (err)
    {
        NSLog(@"WRONG! json");
        return;
    }
    
    for (NSDictionary * dictionary in levels[kDCLevel_levels_key])
    {
        DCLevel * level = [[DCMainProxy sharedProxy] createLevel];
        level.levelId = dictionary[kDCLevel_levelID_key];
        level.name = dictionary[kDCLevel_levelName_key];
        level.order = dictionary[kDCLevel_levelOrder_key];
    }

}

@end
