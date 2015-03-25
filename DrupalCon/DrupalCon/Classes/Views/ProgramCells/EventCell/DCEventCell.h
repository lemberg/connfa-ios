//
//  DCEventCell.h
//  DrupalCon
//
//  Created by Olexandr on 3/10/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCEventCellProtocol;

@interface DCEventCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *highlightedView;

// Event left section (time and icon)
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;

// Event right section 
@property (weak, nonatomic) IBOutlet UIImageView *eventLevelImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstSubtitleButton;
@property (weak, nonatomic) IBOutlet UIButton *secondSubtitleButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdSubtitleButton;

@property (nonatomic,setter=isLastCellInSection:) BOOL isLastCellInSection;

@property (weak, nonatomic) id<DCEventCellProtocol> delegate;

- (void)updateWithTitle:(NSString *)title andPlace:(NSString *)place;

- (void)updateWithTitle:(NSString *)title
               subTitle:(NSString *)eventType
               speakers:(NSString *)speakers
                  place:(NSString *)place;

@end

@protocol DCEventCellProtocol <NSObject>
- (void)didSelectCell:(DCEventCell *)eventCell;
@end