
#import "DCEventCell.h"
#import "DCTimeRange+DC.h"
#import "NSDate+DC.h"
#import "DCEvent+DC.h"
#import "DCTrack.h"
#import "DCSpeaker.h"
#import "DCLevel.h"
#import "DCType.h"
#import "UIImage+Extension.h"

static NSString* ratingsImagesName[] = {@"",
                                        @"ic_experience_beginner",
                                        @"ic_experience_intermediate",
                                        @"ic_experience_advanced"};

// These values are hardcoded because cells are get by "dequeueREusableCells"
// method, so previous cell value might be set to 0.
static NSInteger eventCellSubtitleHeight = 16;
static NSInteger eventCellImageHeight = 16;

#define leftButonEnabledColor [UIColor colorWithWhite:247.0 / 255.0 alpha:1.0]
#define leftButonDisabledColor [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0]

@interface DCEventCell ()

@property(nonatomic) BOOL isEnabled;
@property(weak, nonatomic) IBOutlet UIView* rightContentView;
@property(weak, nonatomic) IBOutlet UIView* leftContentView;
@property(weak, nonatomic) IBOutlet UIButton* rightCoverButton;
@property(weak, nonatomic) IBOutlet UIButton* leftCoverButton;

// Right side constraints
@property(weak, nonatomic)
    IBOutlet NSLayoutConstraint* separatorLeadingConstraint;
@property(weak, nonatomic)
    IBOutlet NSLayoutConstraint* eventTitleLabelTopPadding;
@property(weak, nonatomic)
    IBOutlet NSLayoutConstraint* eventTitleLabelLeftPadding;
@property(weak, nonatomic)
    IBOutlet NSLayoutConstraint* eventTitleLabelRightPadding;

@property(weak, nonatomic)
    IBOutlet NSLayoutConstraint* eventTitleLabelBottomPadding;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint* subtitleBottomPadding;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint* trackViewHeight;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint* speakersViewHeight;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint* placeViewHeight;

// Left side constraints
@property(weak, nonatomic) IBOutlet NSLayoutConstraint* eventImageHeight;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint* startTimeTopPadding;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint* startTimeBottomPadding;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint* endTimeBottomPadding;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint* eventImageBottomPading;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint* leftSideWidth;

@end

@implementation DCEventCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:NO animated:animated];
}

- (CGFloat)getHeightForEvent:(DCEvent*)event isFirstInSection:(BOOL)isFirst {
  // Left side height calculating
  CGFloat startTimeLabelHeight = [self getHeightForLabel:self.startTimeLabel];
  CGFloat endTimeLabelHeight = [self getHeightForLabel:self.endTimeLabel];

  CGFloat leftSideHeight =
      self.startTimeTopPadding.constant + startTimeLabelHeight +
      self.startTimeBottomPadding.constant + endTimeLabelHeight +
      self.endTimeBottomPadding.constant + self.eventImageHeight.constant +
      self.eventImageBottomPading.constant;

  // Right side height calculating
  CGFloat eventTitleHeight = [self getHeightForLabel:self.eventTitleLabel];
  CGFloat rightSideHeight =
      self.eventTitleLabelTopPadding.constant + eventTitleHeight +
      self.eventTitleLabelBottomPadding.constant +
      self.trackViewHeight.constant + self.speakersViewHeight.constant +
      self.placeViewHeight.constant + self.subtitleBottomPadding.constant;

  return leftSideHeight > rightSideHeight ? leftSideHeight : rightSideHeight;
}

- (void)setCellEnabled:(BOOL)enabled {
  self.leftCoverButton.enabled = enabled;
  self.rightCoverButton.enabled = enabled;

  self.leftContentView.backgroundColor =
      enabled ? leftButonEnabledColor : leftButonDisabledColor;
  self.rightContentView.backgroundColor =
      enabled ? [UIColor whiteColor] : leftButonEnabledColor;
}

- (void)initData:(DCEvent*)event delegate:(id<DCEventCellProtocol>)aDelegate {
  NSString* trackName = [(DCTrack*)[event.tracks anyObject] name];

  // Name
  self.eventTitleLabel.text = event.name;
  // this code makes labels in Cell resizable relating to screen size. Cell
  // height with layoutSubviews will work properly
  CGFloat preferredWidth = [UIScreen mainScreen].bounds.size.width -
                           self.leftSideWidth.constant -
                           self.eventTitleLabelLeftPadding.constant -
                           self.eventTitleLabelRightPadding.constant;
  self.eventTitleLabel.preferredMaxLayoutWidth = preferredWidth;

  // Track
  self.trackLabel.text = trackName;
  self.trackViewHeight.constant =
      trackName.length ? eventCellSubtitleHeight : 0;

  // Speakers
  NSString* speakers = [self speakersFromEvent:event];
  self.speakersLabel.text = speakers;
  self.speakersViewHeight.constant =
      speakers.length ? eventCellSubtitleHeight : 0;

  // Place
  self.placeLabel.text = event.place;
  self.placeViewHeight.constant =
      event.place.length ? eventCellSubtitleHeight : 0;

  // Experience level
  NSInteger eventRating = [event.level.levelId integerValue];
  NSString* ratingImageName = ratingsImagesName[eventRating];
  UIImage* ratingImage = ratingImageName.length > 0
                             ? [UIImage imageNamedFromBundle:ratingImageName]
                             : nil;
  if (ratingImage) {
    self.eventLevelImageView.image = ratingImage;
    self.eventLevelImageView.hidden = NO;
  } else {
    self.eventLevelImageView.hidden = YES;
  }

  // Event image (left side)
  UIImage* eventImage = event.imageForEvent;
  if (eventImage) {
    self.eventImageView.image = eventImage;
    self.eventImageView.hidden = NO;
  } else {
    self.eventImageView.hidden = YES;
  }
  self.eventImageHeight.constant =
      self.eventImageView.image ? eventCellImageHeight : 0;

  NSString *timeFormat = ([NSDate is24hourFormat])? @"HH:mm" : @"h:mm aaa";
  // Time  (left side)
  NSString* startTime = [DCDateHelper convertDate:event.startDate
                              toApplicationFormat:timeFormat];
  NSString* endTime =
      [DCDateHelper convertDate:event.endDate toApplicationFormat:timeFormat];

  self.startTimeLabel.text = self.isFirstCellInSection
                                 ? [NSString stringWithFormat:@"%@", startTime]
                                 : nil;
  self.endTimeLabel.text = self.isFirstCellInSection
                               ? [NSString stringWithFormat:@"to %@", endTime]
                               : nil;

  self.separatorLeadingConstraint.constant =
      self.isLastCellInSection ? 0
                               : self.leftSideWidth.constant +
                                     self.eventTitleLabelLeftPadding.constant;

  // setting cell clickable
  self.isEnabled = [self isEnabled:event];
  [self setCellEnabled:self.isEnabled];

  self.delegate = aDelegate;
}

- (BOOL)isEnabled:(DCEvent*)event {
  BOOL disabledByType =
      ((event.type.typeID.integerValue == DC_EVENT_COFEE_BREAK) ||
       (event.type.typeID.integerValue == DC_EVENT_REGISTRATION) ||
       (event.type.typeID.integerValue == DC_EVENT_LUNCH) ||
       (event.type.typeID.integerValue == DC_EVENT_FREE_SLOT) ||
       (event.type.typeID.integerValue == DC_EVENT_NONE));
  return !disabledByType;
}

- (NSString*)speakersFromEvent:(DCEvent*)event {
  NSMutableString* speakersList = [NSMutableString stringWithString:@""];
  for (DCSpeaker* speaker in [event.speakers allObjects]) {
    if (speakersList.length > 0) {
      [speakersList appendString:@", "];
    }

    [speakersList appendString:speaker.name];
  }
  return [NSString stringWithString:speakersList];
}

- (CGFloat)getHeightForLabel:(UILabel*)label {
  CGRect textRect =
      [label.text boundingRectWithSize:CGSizeMake(label.preferredMaxLayoutWidth,
                                                  NSIntegerMax)
                               options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:@{
                              NSFontAttributeName : label.font
                            } context:nil];
  return textRect.size.height;
}

#pragma mark - User actions

- (IBAction)rightContentViewDidClick {
  [self coverButtonDidTouchUp];

  if ([self.delegate conformsToProtocol:@protocol(DCEventCellProtocol)]) {
    [self.delegate didSelectCell:self];
  }
}

- (IBAction)coverButtonDidTouchUp {
  self.highlightedView.hidden = YES;
}

- (IBAction)coverButtonDidTouchDown {
  self.highlightedView.hidden = NO;
}

@end
