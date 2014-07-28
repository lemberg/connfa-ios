//
//  DCAppFacade.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import "DCAppFacade.h"

@implementation DCAppFacade

+(instancetype)shared
{
    static DCAppFacade * _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[DCAppFacade alloc] init];
    });
    
    return _sharedInstance;
}

@end
