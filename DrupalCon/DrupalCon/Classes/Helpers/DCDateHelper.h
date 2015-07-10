//
//  DCDateHelper.h
//  DrupalCon
//
//  Created by Olexandr on 7/7/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDateHelper : NSObject

+ (NSString *)convertDate:(NSDate *)date toApplicationFormat:(NSString *)format;
+ (NSString *)convertDate:(NSDate *)date toDefaultTimeFormat:(NSString *)format;

@end
