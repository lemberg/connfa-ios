//
//  DCEventBaseCell.h
//  DrupalCon
//
//  Created by Macbook on 9/14/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DCLabel;

static NSString *const kHeaderTitle = @"HeaderTitle";
static NSString *const kLeftBlockTitle = @"LeftBlocktitle";
static NSString *const kMiddleBlockTitle = @"MiddleBlockTitle";
static NSString *const kRightBlockTitle = @"RightBlockTitle";

static NSString *const kLeftBlockContent = @"LeftBlockContent";
static NSString *const kMiddleBlockContent = @"MiddleBlockContent";
static NSString *const kRightBlockContent = @"RightBlockContent";

typedef void(^FavoriteButtonPressedCallback)(UITableViewCell *cell, BOOL isSelected);

@interface DCEventBaseCell : UITableViewCell

@property (strong, nonatomic) FavoriteButtonPressedCallback favoriteBtnCallback;

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *leftBlockTitle;
@property (weak, nonatomic) IBOutlet UILabel *middleBlockTitle;
@property (weak, nonatomic) IBOutlet UILabel *rightBlockTitle;

@property (weak, nonatomic) IBOutlet DCLabel *leftBlockContent;
@property (weak, nonatomic) IBOutlet DCLabel *middleBlockContent;
@property (weak, nonatomic) IBOutlet UILabel *rightBlockContent;

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

- (void)favoriteButtonDidSelected:(FavoriteButtonPressedCallback )favoriteButtonPressed;
- (IBAction)favoriteBtnPress:(id)sender;
- (void)setValuesForCell:(NSDictionary *)values;

@end
