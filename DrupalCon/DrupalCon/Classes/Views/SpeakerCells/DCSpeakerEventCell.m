//
//  DCSpeakerEventCell.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCSpeakerEventCell.h"

@implementation DCSpeakerEventCell

- (void)awakeFromNib
{
    [self DC_setStarImage];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected)
    {
        [self setSelected:NO animated:YES];
        self.favorite = !self.isFavorite;
        [self DC_setStarImage];
    }
}

- (void)DC_setStarImage
{
    if (self.isFavorite)
        [_starImg setImage:[UIImage imageNamed:@"star_on"]];

    else
        [_starImg setImage:[UIImage imageNamed:@"star_off"]];
}

+ (float)cellHeight
{
    return 95;
}

@end
