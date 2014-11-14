//
//  NSUserDefaults+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 10/16/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "NSUserDefaults+DC.h"

const NSString * kTimeStampSynchronisation = @"lastUpdate";
const NSString * kAboutInfo = @"aboutHTML";

@implementation NSUserDefaults (DC)

#pragma mark - last modified timestamp

+ (void)updateTimestampString:(NSString *)timestamp ForClass:(Class)aClass
{
    [NSUserDefaults DC_saveObject:timestamp forKey:[NSUserDefaults DC_LastModifiedKeyStringForClass:aClass]];
}

+ (NSString*)lastUpdateForClass:(Class)aClass
{
    NSString * result = [NSUserDefaults DC_savedValueForKey:[NSUserDefaults DC_LastModifiedKeyStringForClass:aClass]];
    return (result?result:@"");
}

#pragma mark - about

+ (void)saveAbout:(NSString*)aboutString
{
    
    [NSUserDefaults DC_saveObject:aboutString forKey:(NSString*)kAboutInfo];
}

+ (NSString*)aboutString
{
    return [NSUserDefaults DC_savedValueForKey:(NSString*)kAboutInfo];
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

+ (NSString*)DC_LastModifiedKeyStringForClass:(Class)aClass
{
    return [NSString stringWithFormat:@"%@_%@", NSStringFromClass(aClass), kTimeStampSynchronisation];
}

@end
