//
//  DCTimeRange.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCTimeRange.h"

@implementation DCTimeRange

-(id) initWithFrom: (NSString*) fromTimeStr to: (NSString*) toTimeStr {
    self = [super init];
    _from = fromTimeStr;
    _to = toTimeStr;
    return self;
}

@end
