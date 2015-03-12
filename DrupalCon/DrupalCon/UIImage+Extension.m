//
//  UIImage+Extension.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 3/12/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "UIImage+Extension.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (initWithColor)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    
    // create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end