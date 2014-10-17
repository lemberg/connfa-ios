//
//  NSUserDefaults+DC.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 10/16/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * kTimeStampSynchronisation;
extern NSString * kAboutInfo;

@interface NSUserDefaults (DC)

#pragma mark - last modified timestamp

+ (void)updateTimestampString:(NSString *)timestamp ForClass:(Class)aClass;
+ (NSString*)lastUpdateForClass:(Class)aClass;

#pragma mark - about
//TODO: shift About to dababase
+ (void)saveAbout:(NSString*)aboutString;
+ (NSString*)aboutString;


@end
