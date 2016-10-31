
#import "DCSpeakerCell.h"
#import "UIImageView+DC.h"
#import "UIImageView+WebCache.h"

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
  [_pictureImg cutCircle];
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
