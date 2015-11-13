//
//  UIColor+Helper.m
//  NewIn
//
//  Created by Pavlo Yonak on 09/12/2014.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "UIColor+Helper.h"

@implementation UIColor (Helper)

+(UIColor *)colorFromHexString:(NSString *)hexString
{
    if (!hexString) return nil;
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
