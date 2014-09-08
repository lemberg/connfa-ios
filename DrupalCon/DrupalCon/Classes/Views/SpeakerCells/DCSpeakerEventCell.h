//
//  DCSpeakerEventCell.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FavoriteButtonPressedCallback)(UITableViewCell *cell, BOOL isSelected);

@interface DCSpeakerEventCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * eventNameValueLbl;
@property (nonatomic, weak) IBOutlet UILabel * eventDateValueLbl;
@property (nonatomic, weak) IBOutlet UILabel * eventTimeValueLbl;
@property (nonatomic, weak) IBOutlet UILabel * eventTrackValueLbl;
@property (nonatomic, weak) IBOutlet UILabel * eventLevelValueLbl;
@property (nonatomic, weak) IBOutlet UIImageView * starImg;

@property (nonatomic, getter = isFavorite) BOOL favorite;

+ (float)cellHeight;
- (void)favoriteButtonDidSelected:(FavoriteButtonPressedCallback )favoriteButtonPressed;

@end
