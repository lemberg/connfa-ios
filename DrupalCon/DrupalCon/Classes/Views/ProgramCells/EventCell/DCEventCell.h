//
//  DCEventCell.h
//  DrupalCon
//
//  Created by Olexandr on 3/10/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCEvent;

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
@property (weak, nonatomic) IBOutlet UILabel *trackLabel;
@property (weak, nonatomic) IBOutlet UILabel *speakersLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;

@property (nonatomic,setter=isLastCellInSection:) BOOL isLastCellInSection;
@property (nonatomic) BOOL isFirstCellInSection;

@property (weak, nonatomic) id<DCEventCellProtocol> delegate;



- (void) initData:(DCEvent*)event delegate:(id<DCEventCellProtocol>)aDelegate;


@end



@protocol DCEventCellProtocol <NSObject>
- (void)didSelectCell:(DCEventCell *)eventCell;
@end