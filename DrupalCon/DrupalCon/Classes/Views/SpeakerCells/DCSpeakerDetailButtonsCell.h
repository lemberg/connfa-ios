//
//  DCSpeakerDetailButtonsCell.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 3/18/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCSpeaker.h"


@interface DCSpeakerDetailButtonsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *webButton;
@property (nonatomic, weak) IBOutlet UIButton *twitterButton;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *webButtonLeftPadding;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *webButtonWidth;


- (void) initData:(DCSpeaker*)speaker;

@end
