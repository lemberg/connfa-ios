//
//  DCEventCell.m
//  DrupalCon
//
//  Created by Olexandr on 3/10/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCEventCell.h"
#import "DCTimeRange+DC.h"

@interface DCEventCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *rightContentView;

@end

@implementation DCEventCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
   
    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}

- (void)isLastCellInSection:(BOOL)isLastCellInSection
{
    _isLastCellInSection = isLastCellInSection;
    // Left offset
    self.separatorLeadingConstraint.constant = (isLastCellInSection)? 0 : 95;
}


- (void)updateWithTitle:(NSString *)title
               subTitle:(NSString *)eventType
               speakers:(NSString *)speakers
                  place:(NSString *)place
{
    [self resetAllContent];
    self.eventTitleLabel.text = title;
    [self updateButton:self.firstSubtitleButton withTitle:eventType];
    [self updateButton:self.secondSubtitleButton withTitle:speakers];
    [self updateButton:self.thirdSubtitleButton withTitle:place];

}

- (void)updateButton:(UIButton *)button withTitle:(NSString *)title
{
    button.hidden = (title.length > 0)? NO : YES;
    [button setTitle:title forState:UIControlStateNormal];
}

- (void)updateWithTitle:(NSString *)title andPlace:(NSString *)place
{
    [self resetAllContent];
    
    self.eventTitleLabel.text = title;
    [self updateButton:self.firstSubtitleButton withTitle:place];
    
    [self.firstSubtitleButton setImage:[UIImage imageNamed:@"ic_place"]
                              forState:UIControlStateNormal];

}

- (void)resetAllContent {
    self.startTimeLabel.text = @"";
    self.endTimeLabel.text   = @"";
    self.eventImageView.image = nil;
    self.eventLevelImageView.image = nil;
    self.eventTitleLabel.text = @"";
    
    [self.firstSubtitleButton setImage:nil
                              forState:UIControlStateNormal];
    
    self.firstSubtitleButton.hidden = YES;
    self.secondSubtitleButton.hidden = YES;
    self.thirdSubtitleButton.hidden = YES;

}

- (IBAction)selectRightContent:(id)sender {
    if ([self.delegate conformsToProtocol:@protocol(DCEventCellProtocol)]) {
        [self.delegate didSelectCell:self];
    }
}

@end
