//
//  DCHeaderView.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/31/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCProgramHeaderCellView : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *leftImageView;
@property (nonatomic, weak) IBOutlet UILabel *startLabel;
@property (nonatomic, weak) IBOutlet UILabel *endLabel;
@end
