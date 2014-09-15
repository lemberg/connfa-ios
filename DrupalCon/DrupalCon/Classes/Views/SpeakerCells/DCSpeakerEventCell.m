//
//  DCSpeakerEventCell.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCSpeakerEventCell.h"
@interface DCSpeakerEventCell ()

@property (strong, nonatomic) FavoriteButtonPressedCallback favoriteBtnCallback;

@end
@implementation DCSpeakerEventCell

//- (void)awakeFromNib
//{
////    [super awakeFromNib];
//    [self DC_setStarImage];
//    UIView *bgColorView = [[UIView alloc] init];
//    float value = 238./255.;
//    bgColorView.backgroundColor = [UIColor colorWithRed:value green:value blue:value alpha:1.0];
//    [self setSelectedBackgroundView:bgColorView];
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected)
    {
        [self setSelected:NO animated:YES];
//        self.favorite = !self.isFavorite;
//        [self DC_setStarImage];
//        if (self.favoriteBtnCallback) {
//           self.favoriteBtnCallback(self, self.isFavorite);
//        }
        [self favoriteBtnPress:self.favoriteButton];
    }
}

//- (void)DC_setStarImage
//{
//    if (self.isFavorite)
//        [_starImg setImage:[UIImage imageNamed:@"star_on"]];
//
//    else
//        [_starImg setImage:[UIImage imageNamed:@"star_off"]];
//
//}

+ (float)cellHeight
{
    return 95;
}

@end
