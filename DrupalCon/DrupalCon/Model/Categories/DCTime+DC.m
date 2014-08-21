//
//  DCTime+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/21/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCTime+DC.h"

@implementation DCTime (DC)

- (void)setTime:(NSString *)time
{
    NSArray * components = [time componentsSeparatedByString:@":"];
    if (components.count != 2)
        NSLog(@"WRONG! time format");
    
    self.hour = [self numberFromString:components[0]];
    self.minute = [self numberFromString:components[1]];
}

- (NSNumber*)numberFromString:(NSString*)string
{
    return [NSNumber numberWithInteger:[string integerValue]];
}

@end
