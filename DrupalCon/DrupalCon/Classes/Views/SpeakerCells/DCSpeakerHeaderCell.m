//
//  DCSpeakerHeaderCell.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/27/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCSpeakerHeaderCell.h"
#import "UIImageView+DC.h"

@implementation DCSpeakerHeaderCell


- (void)awakeFromNib
{
    [_pictureImg cutCircle];
    [_pictureImg addCircuitWidth:2.0 color:[UIColor whiteColor]];
}

+ (float)cellHeight
{
    return 210.0;
}

@end
