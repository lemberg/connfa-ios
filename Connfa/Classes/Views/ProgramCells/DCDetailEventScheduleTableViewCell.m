//
//  DCDetailEventScheduleTableViewCell.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 4/27/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCDetailEventScheduleTableViewCell.h"

@implementation DCDetailEventScheduleTableViewCell

- (void)awakeFromNib {
  [super awakeFromNib];
  [self.scheduleName setFont:[UIFont fontWithName:@".SFUIText-Regular" size:16.5]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

@end
