//
//  DCSpeakerCell.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/26/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCSpeakerCell.h"
#import "UIImageView+DC.h"

@implementation DCSpeakerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [_pictureImg cutCircle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (float)cellHeight
{
    return 65.0;
}

@end
