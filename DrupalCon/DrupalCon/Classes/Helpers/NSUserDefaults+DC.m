//
//  NSUserDefaults+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 10/16/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "NSUserDefaults+DC.h"

static NSString * kTimeStampSynchronisation = @"lastUpdate";
static NSString * kAboutInfo = @"aboutHTML";

@implementation NSUserDefaults (DC)

#pragma mark - timeStamp

+ (void)updateTimestampString:(NSString *)timestamp
{
    [NSUserDefaults DC_saveObject:timestamp forKey:kTimeStampSynchronisation];
}

+ (NSString*)lastUpdates
{
    return [NSUserDefaults DC_savedValueForKey:kTimeStampSynchronisation];
}


#pragma mark - about

+ (void)saveAbout:(NSString*)aboutString
{
    [NSUserDefaults DC_saveObject:aboutString forKey:kAboutInfo];
}

+ (NSString*)aboutString
{
    return [NSUserDefaults DC_savedValueForKey:kAboutInfo];
}


#pragma mark - private

+ (void)DC_saveObject:(NSObject *)obj forKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:obj forKey:key];
    [userDefaults synchronize];
}

+ (id)DC_savedValueForKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:key];
}

@end
