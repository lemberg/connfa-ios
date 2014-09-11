//
//  DCSpeechBaseCell.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 9/11/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^FavoriteButtonPressedCallback)(UITableViewCell *cell, BOOL isSelected);

@interface DCSpeechBaseCell : UITableViewCell

@property (strong, nonatomic) FavoriteButtonPressedCallback favoriteBtnCallback;


@property (nonatomic, weak) IBOutlet UILabel *speakerLabel;
@property (nonatomic, weak) IBOutlet UILabel *trackLabel;
@property (nonatomic, weak) IBOutlet UILabel *experienceLevelLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@property (nonatomic, weak) IBOutlet UILabel *levelBlockNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *speakerBlockNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *trackBlockNameLabel;

- (void)favoriteButtonDidSelected:(FavoriteButtonPressedCallback )favoriteButtonPressed;
- (IBAction)favoriteBtnPress:(id)sender;

- (void)setTrack:(NSString*)trackStr;
- (void)setLevel:(NSString*)levelStr;
- (void)setSpeakers:(NSString*)speakers;

@end
