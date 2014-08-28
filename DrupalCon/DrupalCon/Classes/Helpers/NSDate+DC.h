//
//  NSDate+DC.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/21/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DC)

+ (NSDate*)fabricateWithEventString:(NSString*)string;
- (NSString*)pageViewDateString;
- (NSString*)stringForSpeakerEventCell;

@end
