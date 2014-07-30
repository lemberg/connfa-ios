//
//  DCSpeechCell.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCSpeechCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *speakerLabel;
@property (nonatomic, weak) IBOutlet UILabel *trackLabel;
@property (nonatomic, weak) IBOutlet UILabel *experienceLevelLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end
