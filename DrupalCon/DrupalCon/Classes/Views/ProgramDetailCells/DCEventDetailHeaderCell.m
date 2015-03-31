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


@implementation DCEventDetailHeaderCell

- (void) initData:(DCEvent *)event
{
    self.titleLabel.text = event.name;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"MM-dd HH:mm"];
    NSString *date = event.date ? [formatter stringFromDate: event.date] : @"";
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
