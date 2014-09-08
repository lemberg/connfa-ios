//
//  DCSpeechOfDayCell.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCSpeechOfDayCell.h"
@interface DCSpeechOfDayCell ()

@property (strong, nonatomic) FavoriteButtonPressedCallback favoriteBtnCallback;
- (IBAction)favoriteBtnPress:(id)sender;

@end

@implementation DCSpeechOfDayCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.favoriteButton.exclusiveTouch = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)favoriteButtonDidSelected:(FavoriteButtonPressedCallback )callback
{
    self.favoriteBtnCallback = callback;
}

- (IBAction)favoriteBtnPress:(id)sender {
    UIButton *fvBtn = (UIButton *)sender;
    if ([sender isSelected]) {
        fvBtn.selected = NO;
    } else {
        fvBtn.selected = YES;
    }
    self.favoriteBtnCallback(self, fvBtn.isSelected);
}
@end
