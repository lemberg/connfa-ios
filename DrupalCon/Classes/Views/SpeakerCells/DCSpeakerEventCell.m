
#import "DCSpeakerEventCell.h"
#import "DCTrack.h"
#import "DCLevel.h"
#import "DCEvent+DC.h"
#import "DCTime+DC.h"
#import "DCTimeRange+DC.h"
#import "NSDate+DC.h"
#import "UIImage+Extension.h"

@interface DCSpeakerEventCell ()

@end

@implementation DCSpeakerEventCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  if (selected) {
    [self setSelected:NO animated:YES];

    // favorite button press handle
  }
}

- (void)initData:(DCEvent*)event {
  // event Name
  self.eventNameLabel.text = event.name;

  // event Date
  NSString* date =
      event.date
          ? [DCDateHelper convertDate:event.date toApplicationFormat:@"EEE"]
          : @"";
  NSString* startTime = [DCDateHelper convertDate:event.startDate
                              toApplicationFormat:@"h:mm aaa"];
  NSString* endTime =
      [DCDateHelper convertDate:event.endDate toApplicationFormat:@"h:mm aaa"];
  date = [NSString
      stringWithFormat:@"%@, %@ - %@", [date uppercaseString],
                       startTime,  //[NSDate hourFormatForDate:event.startDate
                       // andTimeZone:eventTimeZone],
                       endTime];  //[NSDate hourFormatForDate:event.endDate
  // andTimeZone:eventTimeZone]];

  NSString* place = event.place ? event.place : @"";

  if (date.length && place.length)
    self.eventTimeLabel.text =
        [NSString stringWithFormat:@"%@ in %@", date, place];
  else
    self.eventTimeLabel.text = [NSString stringWithFormat:@"%@%@", date, place];

  // event Track
  self.eventTrackLabel.text = [(DCTrack*)[event.tracks anyObject] name];

  // event experience Level
  if (event.level.name.length) {
    self.eventLevelLabel.text =
        [NSString stringWithFormat:@"Experience level: %@", event.level.name];
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
    self.eventLevelLabel.text = nil;
    self.experienceIcon.hidden = YES;
    self.experienceIcon.frame = CGRectZero;
  }

  // this code makes labels in Cell resizable relating to screen size. Cell
  // height with layoutSubviews will work properly
  CGFloat preferredWidth = [UIScreen mainScreen].bounds.size.width -
                           self.labelsCommonSidePadding.constant * 2;
  self.eventNameLabel.preferredMaxLayoutWidth = preferredWidth;
  self.eventTimeLabel.preferredMaxLayoutWidth = preferredWidth;
  self.eventTrackLabel.preferredMaxLayoutWidth = preferredWidth;
}

@end
