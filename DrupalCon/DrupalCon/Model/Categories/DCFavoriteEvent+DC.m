//
//  DCFavoriteEvent+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 10/17/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCFavoriteEvent+DC.h"
#import "DCEvent+DC.h"

@implementation DCFavoriteEvent (DC)

+ (NSString*)idKey
{
    return [DCEvent idKey];
}

@end
