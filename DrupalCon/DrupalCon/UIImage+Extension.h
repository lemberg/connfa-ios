//
//  UIImage+Extension.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 3/12/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIImage (initWithColor)

    //programmatically create an UIImage with 1 pixel of a given color
+ (UIImage *)imageWithColor:(UIColor *)color;

    //implement additional methods here to create images with gradients etc.
    //[..]

@end

