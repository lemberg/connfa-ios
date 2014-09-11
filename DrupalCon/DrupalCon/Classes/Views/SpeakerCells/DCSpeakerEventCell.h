//
//  DCSpeakerEventCell.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCSpeechBaseCell.h"


@interface DCSpeakerEventCell : DCSpeechBaseCell

@property (nonatomic, weak) IBOutlet UILabel * eventDateValueLbl;
@property (nonatomic, weak) IBOutlet UILabel * eventTimeValueLbl;
@property (nonatomic, weak) IBOutlet UIImageView * starImg;

@property (nonatomic, getter = isFavorite) BOOL favorite;

+ (float)cellHeight;

@end
