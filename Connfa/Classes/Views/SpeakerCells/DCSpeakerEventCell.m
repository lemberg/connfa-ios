
#import "DCSpeakerEventCell.h"
#import "DCTrack.h"
#import "DCLevel.h"
#import "DCEvent+DC.h"
#import "DCTime+DC.h"
#import "DCTimeRange+DC.h"
#import "NSDate+DC.h"
#import "UIImage+Extension.h"
#import "DCConstants.h"
#import "DCFontItem.h"

@interface DCSpeakerEventCell ()

@end

@implementation DCSpeakerEventCell

- (void) awakeFromNib {
  [super awakeFromNib];
  [self setCustomFonts];
  [self layoutIfNeeded];
}

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
  NSString *timeFormat;
  
  if ([NSDate is24hourFormat]) {
    timeFormat = @"H:mm aaa";
  } else {
    timeFormat = @"h:mm aaa";
  }
  
  
  // event Date
  NSString* date =
      event.date
          ? [event.date dateToStringWithFormat:@"EEE"]
          : @"";
  NSString* startTime = [DCDateHelper convertDate:event.startDate
                              toApplicationFormat:timeFormat];
  NSString* endTime =
      [DCDateHelper convertDate:event.endDate toApplicationFormat:timeFormat];
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

- (void)setCustomFonts {
  
  DCFontItem *fonts = [DCConstants appFonts].firstObject;

  self.eventNameLabel.font = [UIFont fontWithName:fonts.nameFont size:self.eventNameLabel.font.pointSize];
  self.eventTimeLabel.font = [UIFont fontWithName:fonts.descriptionFont size:self.eventTimeLabel.font.pointSize];
  self.eventTrackLabel.font = [UIFont fontWithName:fonts.descriptionFont size:self.eventTrackLabel.font.pointSize];
  self.eventLevelLabel.font = [UIFont fontWithName:fonts.descriptionFont size:self.eventLevelLabel.font.pointSize];
  
}


@end
