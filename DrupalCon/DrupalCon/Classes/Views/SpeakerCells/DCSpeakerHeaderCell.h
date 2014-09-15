//
//  DCSpeakerHeaderCell.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/27/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCSpeakerHeaderCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView * pictureImg;
@property (nonatomic, weak) IBOutlet UILabel * nameLbl;
@property (nonatomic, weak) IBOutlet UILabel * organizationLbl;
@property (nonatomic, weak) IBOutlet UILabel * jobTitleLbl;
@property (weak, nonatomic) IBOutlet UIButton *webButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UILabel *organizationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobTitleLabel;

+ (float)cellHeight;

@end
