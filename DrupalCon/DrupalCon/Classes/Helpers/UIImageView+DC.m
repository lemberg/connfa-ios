//
//  UIImageView+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/27/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "UIImageView+DC.h"

@implementation UIImageView (DC)

- (void)cutCircle
{
    float biger_side = (self.frame.size.width > self.frame.size.height ? self.frame.size.width : self.frame.size.height);
    CALayer * la = self.layer;
    la.masksToBounds = YES;
    la.cornerRadius = biger_side/2;
    la.borderWidth = 0;
}

- (void)addCircuitWidth:(float)width color:(UIColor*)color
{
    CALayer * la = self.layer;
    la.masksToBounds = YES;
    la.borderColor = color.CGColor;
    la.borderWidth = width;
}

@end
