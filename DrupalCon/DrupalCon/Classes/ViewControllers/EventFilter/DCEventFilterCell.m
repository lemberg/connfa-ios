//
//  DCEventFilterCell.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 2/24/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCEventFilterCell.h"

@implementation DCEventFilterCell

- (void)awakeFromNib
{
    self.checkBox.delegate = self;
}

- (void)DCFilterCheckBox:(DCFilterCheckBox*)checkBox didChangedState:(BOOL)isSelected
{
    [self.delegate cellCheckBoxDidSelected: isSelected
                                  cellType: self.type
                           relatedObjectId: self.relatedObjectId];
}

@end
