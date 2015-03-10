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
extern NSString * kBundleVersionMajor;
extern NSString * kBundleVersionMinor;

@interface NSUserDefaults (DC)

#pragma mark - last modified timestamp
#warning timestamp is substitute by last-modify parameter
+ (void)updateTimestampString:(NSString *)timestamp ForClass:(Class)aClass;
+ (NSString*)lastUpdateForClass:(Class)aClass;

#pragma mark - last-modify

+ (void)updateLastModify:(NSString*)lastModify;
+ (NSString*)lastModify;

#pragma mark - about
//TODO: shift About to dababase
+ (void)saveAbout:(NSString*)aboutString;
+ (NSString*)aboutString;

#pragma mark - bundle version

+ (void)saveBundleVersionMajor:(NSString*)major minor:(NSString*)minor;
+ (NSString*)bundleVersionMajor;
+ (NSString*)bundleVersionMinor;


@end
