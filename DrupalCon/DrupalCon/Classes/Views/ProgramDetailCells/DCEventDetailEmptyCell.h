//
//  DCEventDetailEmptyCell.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/27/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCEventDetailEmptyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *triangleImageView;

+ (CGFloat)cellHeight;

@end
