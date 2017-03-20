
#import "DCSpeakerCell.h"
#import "UIImageView+DC.h"
#import "UIImageView+WebCache.h"
#import "DCConstants.h"
#import "DCFontItem.h"

@interface DCSpeakerCell()
@property(nonatomic, weak) DCSpeaker *currentSpeaker;
@end


@implementation DCSpeakerCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  [self setSpeaker:self.currentSpeaker];
  [_pictureImg cutCircle];
  [self setCustomFonts];
  [self layoutIfNeeded];
}

- (void)setSpeaker:(DCSpeaker*)speaker; {
  self.currentSpeaker = speaker;
  [self.nameLbl setText:self.currentSpeaker.name];
  
  [self.positionTitleLbl setText:[self positionTitleForSpeaker:self.currentSpeaker]];
  [self.pictureImg
   sd_setImageWithURL:[NSURL URLWithString:self.currentSpeaker.avatarPath]
   placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]
   completed:^(UIImage* image, NSError* error,
               SDImageCacheType cacheType, NSURL* imageURL) {
     dispatch_async(dispatch_get_main_queue(), ^{
       [self setNeedsDisplay];
     });
   }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

+ (float)cellHeight {
  return 52.0;
}

- (void)initData:(DCSpeaker*)speaker {
  [self.pictureImg
      sd_setImageWithURL:[NSURL URLWithString:speaker.avatarPath]
        placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]
               completed:^(UIImage* image, NSError* error,
                           SDImageCacheType cacheType, NSURL* imageURL) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                   [self setNeedsDisplay];
                 });
               }];

  [self.nameLbl setText:speaker.name];
  [self.positionTitleLbl setText:[self positionTitleForSpeaker:speaker]];

  // this code makes labels in Cell resizable relating to screen size. Cell
  // height with layoutSubviews will work properly
  CGFloat preferredWidth = [UIScreen mainScreen].bounds.size.width - 85;
  self.nameLbl.preferredMaxLayoutWidth = preferredWidth;
  self.positionTitleLbl.preferredMaxLayoutWidth = preferredWidth;
}

- (void)setCustomFonts {

  DCFontItem *fonts = [DCConstants appFonts].firstObject;
  
  self.nameLbl.font = [UIFont fontWithName:fonts.nameFont size:self.nameLbl.font.pointSize];
  self.positionTitleLbl.font = [UIFont fontWithName:fonts.descriptionFont size:self.positionTitleLbl.font.pointSize];
}

- (NSString*)positionTitleForSpeaker:(DCSpeaker*)speaker {
  NSString* organisationName = speaker.organizationName;
  NSString* jobTitle = speaker.jobTitle;
  if ([jobTitle length] && [organisationName length]) {
    return [NSString stringWithFormat:@"%@ / %@", organisationName, jobTitle];
  }
  if (![jobTitle length]) {
    return organisationName.length ? organisationName : @" ";
  }

  return jobTitle.length ? jobTitle : @" ";
}

@end
