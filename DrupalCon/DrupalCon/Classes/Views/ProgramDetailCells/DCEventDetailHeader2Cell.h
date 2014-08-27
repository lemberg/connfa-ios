//
//  DCEventDetailHeader2Cell.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/27/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFavoriteButton.h"

@interface DCEventDetailHeader2Cell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * trackValueLbl;
@property (nonatomic, weak) IBOutlet UILabel * levelValueLbl;
@property (nonatomic, weak) IBOutlet UILabel * placeValueLbl;
@property (nonatomic, weak) IBOutlet DCFavoriteButton * favorBtn;

+ (CGFloat)cellHeight;

@end
