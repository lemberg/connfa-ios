//
//  DCLunchCell.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCLunchCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *leftImageView;
@property (nonatomic, weak) IBOutlet UILabel *startLabel;
@property (nonatomic, weak) IBOutlet UILabel *endLabel;
@end
