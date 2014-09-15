//
//  DCSpeechBaseCell.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 9/11/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCSpeechBaseCell.h"

@implementation DCSpeechBaseCell

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
    UIView *bgColorView = [[UIView alloc] init];
    float value = 238./255.;
    bgColorView.backgroundColor = [UIColor colorWithRed:value green:value blue:value alpha:1.0];
    [self setSelectedBackgroundView:bgColorView];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark -

-(void)setTrack:(NSString *)trackStr
{
    if (trackStr.length == 0)
    {
        self.trackBlockNameLabel.hidden = YES;
        self.trackLabel.hidden = YES;
    }
    else
    {
        self.trackBlockNameLabel.hidden = NO;
        self.trackLabel.hidden = NO;
        self.trackLabel.text = trackStr;
    }
    

}

- (void)setLevel:(NSString *)levelStr
{
    if (levelStr.length == 0)
    {
        self.levelBlockNameLabel.hidden = YES;
        self.experienceLevelLabel.hidden = YES;
    }
    else
    {
        self.levelBlockNameLabel.hidden = NO;
        self.experienceLevelLabel.hidden = NO;
        self.experienceLevelLabel.text = levelStr;
    }
}

- (void)setSpeakers:(NSString *)speakers
{
    if (speakers.length == 0)
    {
        self.speakerBlockNameLabel.hidden = YES;
        self.speakerLabel.hidden = YES;
    }
    else
    {
        self.speakerBlockNameLabel.hidden = NO;
        self.speakerLabel.hidden = NO;
        self.speakerLabel.text = speakers;
    }
}

#pragma mark -

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
