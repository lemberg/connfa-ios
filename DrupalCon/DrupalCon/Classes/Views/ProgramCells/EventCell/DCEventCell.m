//
//  DCEventCell.m
//  DrupalCon
//
//  Created by Olexandr on 3/10/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCEventCell.h"
#import "DCTimeRange+DC.h"

#import "DCEvent+DC.h"
#import "DCTrack.h"
#import "DCSpeaker.h"
#import "DCLevel.h"

static NSString *ratingsImagesName[] = {@"", @"ic_experience_beginner", @"ic_experience_intermediate", @"ic_experience_advanced" };
static NSInteger eventCellSubtitleHeight = 14;
static NSInteger eventCellImageHeight = 16;

@interface DCEventCell()

@property (weak, nonatomic) IBOutlet UIView *rightContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorLeadingConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trackViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speakersViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *placeViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventImageHeight;

@end

@implementation DCEventCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];
}

- (NSString *)hourFormatForDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm aaa"];
    NSString *dateDisplay = [dateFormatter stringFromDate:date];
    return  dateDisplay;
}

- (void) initData:(DCEvent*)event delegate:(id<DCEventCellProtocol>)aDelegate
{
    NSString *trackName = [(DCTrack*)[event.tracks anyObject] name];
    
        // Name
    self.eventTitleLabel.text = event.name;
        // this code makes labels in Cell resizable relating to screen size. Cell height with layoutSubviews will work properly
    CGFloat preferredWidth = [UIScreen mainScreen].bounds.size.width - 77 - 9 - 28;
    self.eventTitleLabel.preferredMaxLayoutWidth = preferredWidth;
    
        // Track
    self.trackLabel.text = trackName;
    self.trackViewHeight.constant = trackName.length ? eventCellSubtitleHeight : 0;
    
        // Speakers
    NSString* speakers = [self speakersFromEvent:event];
    self.speakersLabel.text = speakers;
    self.speakersViewHeight.constant = speakers.length ? eventCellSubtitleHeight : 0;
    
        // Place
    self.placeLabel.text = event.place;
    self.placeViewHeight.constant = event.place.length ? eventCellSubtitleHeight : 0;
    
        // Experience level
    NSInteger eventRating = [event.level.levelId integerValue];
    NSString *ratingImageName = ratingsImagesName[eventRating];
    self.eventLevelImageView.image = [UIImage imageNamed:ratingImageName];
    
        // Event image (left side)
    self.eventImageView.image = event.imageForEvent;
    self.eventImageHeight.constant = self.eventImageView.image ? eventCellImageHeight : 0;
    
        // Time  (left side)
    self.startTimeLabel.text = self.isFirstCellInSection ? [self hourFormatForDate:event.startDate] : nil;
    self.endTimeLabel.text  = self.isFirstCellInSection ? [NSString stringWithFormat:@"to %@", [self hourFormatForDate:event.endDate]] : nil;

    self.separatorLeadingConstraint.constant = self.isLastCellInSection? 0 : 77 + 9;
    
    self.delegate = aDelegate;
}

- (NSString *)speakersFromEvent:(DCEvent *)event
{
    NSMutableString *speakersList = [NSMutableString stringWithString:@""];
    for (DCSpeaker *speaker in [event.speakers allObjects]) {
        if (speakersList.length > 0) {
            [speakersList appendString:@", "];
        }
        
        [speakersList appendString:speaker.name];
    }
    return [NSString stringWithString:speakersList];
}

#pragma mark - User actions

- (IBAction) rightContentViewDidClick
{
    [self coverButtonDidTouchUp];
    
    if ([self.delegate conformsToProtocol:@protocol(DCEventCellProtocol)]) {
        [self.delegate didSelectCell:self];
    }
}

- (IBAction) coverButtonDidTouchUp
{
    self.highlightedView.hidden = YES;
}

- (IBAction) coverButtonDidTouchDown
{
    self.highlightedView.hidden = NO;
}


@end
