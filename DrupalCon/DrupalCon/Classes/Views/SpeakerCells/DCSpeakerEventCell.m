//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DCSpeakerEventCell.h"
#import "DCTrack.h"
#import "DCLevel.h"
#import "DCEvent+DC.h"
#import "DCTime+DC.h"
#import "DCTimeRange+DC.h"
#import "NSDate+DC.h"

@interface DCSpeakerEventCell ()

@end



@implementation DCSpeakerEventCell



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected)
    {
        [self setSelected:NO animated:YES];

        // favorite button press handle
    }
}

- (void) initData:(DCEvent*)event
{
        // event Name
    self.eventNameLabel.text = event.name;
    
        // event Date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"EEE"];
    
    NSString *date = event.date ? [formatter stringFromDate: event.date] : @"";
    
    date = [NSString stringWithFormat:@"%@, %@ - %@", [date uppercaseString], [NSDate hourFormatForDate:event.startDate], [NSDate hourFormatForDate:event.endDate]];


    NSString *place = event.place ? event.place : @"";
    
    if (date.length && place.length)
        self.eventTimeLabel.text = [NSString stringWithFormat: @"%@ in %@", date, place];
    else
        self.eventTimeLabel.text = [NSString stringWithFormat: @"%@%@", date, place];
    
        // event Track
    self.eventTrackLabel.text = [(DCTrack*)[event.tracks anyObject] name];
    
        // event experience Level
    if (event.level.name.length)
    {
        self.eventLevelLabel.text = [NSString stringWithFormat:@"Experience level: %@", event.level.name];
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
    } else
    {
        self.eventLevelLabel.text = nil;
        self.experienceIcon.hidden = YES;
        self.experienceIcon.frame = CGRectZero;
    }
    
        // this code makes labels in Cell resizable relating to screen size. Cell height with layoutSubviews will work properly
    CGFloat preferredWidth = [UIScreen mainScreen].bounds.size.width - self.labelsCommonSidePadding.constant*2;
    self.eventNameLabel.preferredMaxLayoutWidth = preferredWidth;
    self.eventTimeLabel.preferredMaxLayoutWidth = preferredWidth;
    self.eventTrackLabel.preferredMaxLayoutWidth = preferredWidth;

}



@end
