/**********************************************************************************
 *                                                                           
 *  The MIT License (MIT)
 *  Copyright (c) 2015 Lemberg Solutions Limited
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the 
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *   The above copyright notice and this permission notice shall be included in
 *   all  copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM,  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 *  IN THE SOFTWARE.
 *
 *                                                                           
 *****************************************************************************/



#import "DCEventDetailHeaderCell.h"
#import "DCLevel.h"
#import "DCTrack.h"
#import "DCTimeRange+DC.h"
#import "NSDate+DC.h"
#import "DCEvent+DC.h"
#import "UIImage+Extension.h"

@implementation DCEventDetailHeaderCell

- (void)initData:(DCEvent*)event {
  // this code makes labels in Cell resizable relating to screen size. Cell
  // height with layoutSubviews will work properly
  CGFloat preferredWidth = [UIScreen mainScreen].bounds.size.width - 30;
  self.titleLabel.preferredMaxLayoutWidth = preferredWidth;
  self.dateAndPlaceLabel.preferredMaxLayoutWidth = preferredWidth;

  self.titleLabel.text = event.name;

  NSString* date =
      event.date
          ? [DCDateHelper convertDate:event.date toApplicationFormat:@"EEE"]
          : @"";
  NSString* startTime = [DCDateHelper convertDate:event.startDate
                              toApplicationFormat:@"h:mm aaa"];
  NSString* endTime =
      [DCDateHelper convertDate:event.endDate toApplicationFormat:@"h:mm aaa"];
  date = [NSString stringWithFormat:@"%@, %@ - %@", [date uppercaseString],
                                    startTime, endTime];

  self.eventDetailContainerView.backgroundColor =
      [DCAppConfiguration eventDetailHeaderColour];
  NSString* place = event.place ? event.place : @"";

  if (date.length && place.length)
    self.dateAndPlaceLabel.text =
        [NSString stringWithFormat:@"%@ in %@", date, place];
  else
    self.dateAndPlaceLabel.text =
        [NSString stringWithFormat:@"%@%@", date, place];

  DCTrack* track = [event.tracks anyObject];
  DCLevel* level = event.level;

  BOOL shouldHideTrackAndLevelView =
      (track.trackId.integerValue == 0 && level.levelId.integerValue == 0);

  if (!shouldHideTrackAndLevelView) {
    self.trackLabel.text = [(DCTrack*)[event.tracks anyObject] name];
    self.experienceLabel.text =
        event.level.name ? [NSString stringWithFormat:@"Experience level: %@",
                                                      event.level.name]
                         : nil;

    UIImage* icon = nil;
    switch (event.level.levelId.integerValue) {
      case 1:
        icon = [UIImage imageNamedFromBundle:@"ic_experience_beginner"];
        break;
      case 2:
        icon = [UIImage imageNamedFromBundle:@"ic_experience_intermediate"];
        break;
      case 3:
        icon = [UIImage imageNamedFromBundle:@"ic_experience_advanced"];
        break;
      default:
        break;
    }
    self.experienceIcon.image = icon;
  } else {
    self.trackAndLevelViewHeight.priority = 900;
    self.TrackAndLevelView.hidden = YES;
  }
}

@end
