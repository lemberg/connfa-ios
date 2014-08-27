//
//  DCEventDetailTitleCell.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/27/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCEventDetailTitleCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * titleLbl;

+ (CGFloat)cellHeight;

@end
