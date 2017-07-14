//
//  DCDetailEventHeaderTableViewCell.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 4/27/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCDetailEventHeaderTableViewCell.h"

@implementation DCDetailEventHeaderTableViewCell

- (void)awakeFromNib {
  [super awakeFromNib];
  [self.headerLabel setFont:[UIFont fontWithName:@".SFUIText-Semibold" size:12.5]];
  [self.headerLabel setTextColor:[UIColor colorWithRed:101/255. green:182/255. blue:180/255. alpha:1.]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

@end
