//
//  NSUserDefaults+DC.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 10/16/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (DC)


+ (void)updateTimestampString:(NSString*)timestamp;
+ (NSString*)lastUpdates;

#pragma mark - about
//TODO: shift About to dababase
+ (void)saveAbout:(NSString*)aboutString;
+ (NSString*)aboutString;

@end
