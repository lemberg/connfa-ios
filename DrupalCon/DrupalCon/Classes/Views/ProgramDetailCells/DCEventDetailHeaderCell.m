//
//  DCEventDetailHeaderCell.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 3/27/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCEventDetailHeaderCell.h"
#import "DCLevel.h"
#import "DCTrack.h"
#import "DCTimeRange+DC.h"
#import "NSDate+DC.h"
#import "DCEvent+DC.h"


@implementation DCEventDetailHeaderCell

- (void) initData:(DCEvent *)event
{
    self.titleLabel.text = event.name;
    
    // event Date
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat: @"EEE"];
    
    NSString *date = event.date ? [DCDateHelper convertDate:event.date toApplicationFormat:@"EEE"] : @"";
    NSString *startTime = [DCDateHelper convertDate:event.startDate toApplicationFormat:@"h:mm aaa"];
    NSString *endTime   = [DCDateHelper convertDate:event.endDate toApplicationFormat:@"h:mm aaa"];
    date = [NSString stringWithFormat:@"%@, %@ - %@",
            [date uppercaseString],
            startTime,
            endTime];
    
    
    NSString *place = event.place ? event.place : @"";
    
    if (date.length && place.length)
        self.dateAndPlaceLabel.text = [NSString stringWithFormat: @"%@ in %@", date, place];
    else
        self.dateAndPlaceLabel.text = [NSString stringWithFormat: @"%@%@", date, place];
    
    
    DCTrack* track = [event.tracks anyObject];
    DCLevel* level = event.level;
    
    BOOL shouldHideTrackAndLevelView = (track.trackId.integerValue == 0 && level.levelId.integerValue == 0);
    
    if (!shouldHideTrackAndLevelView)
    {
        self.trackLabel.text = [(DCTrack*)[event.tracks anyObject] name];
        self.experienceLabel.text = event.level.name ? [NSString stringWithFormat:@"Experience level: %@", event.level.name] : nil;
        
        UIImage* icon = nil;
        switch (event.level.levelId.integerValue)
        {
            case 1:
                icon = [UIImage imageNamed:@"ic_experience_beginner"];
                break;
            case 2:
                icon = [UIImage imageNamed:@"ic_experience_intermediate"];
                break;
            case 3:
                icon = [UIImage imageNamed:@"ic_experience_advanced"];
                break;
            default:
                break;
        }
        self.experienceIcon.image = icon;
    }
    else
    {
        self.trackAndLevelViewHeight.priority = 900;
        self.TrackAndLevelView.hidden = YES;
    }
}

@end
