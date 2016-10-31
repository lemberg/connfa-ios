
#import "DCSpeakerHeaderCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+DC.h"
#import "DCSpeaker.h"

@implementation DCSpeakerHeaderCell

- (void)awakeFromNib {
  [self.photoImageView cutCircle];
}

- (void)initData:(DCSpeaker*)speaker {
  // Photo image
  [self.photoImageView
      sd_setImageWithURL:[NSURL URLWithString:speaker.avatarPath]
        placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]
               completed:^(UIImage* image, NSError* error,
                           SDImageCacheType cacheType, NSURL* imageURL) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                   [self setNeedsDisplay];
                 });

               }];

  // Name text
  self.nameLabel.text = speaker.name;

  // Job and Company text
  NSMutableString* jobAndCompany = speaker.jobTitle.length
                                       ? [speaker.jobTitle mutableCopy]
                                       : [@"" mutableCopy];
  if (speaker.organizationName.length)
    [jobAndCompany
        appendString:speaker.jobTitle.length
                         ? [NSString stringWithFormat:@" at %@",
                                                      speaker.organizationName]
                         : speaker.organizationName];
  self.jobAndCompanyLabel.text = jobAndCompany;

  // this code makes labels in Cell resizable relating to screen size. Cell
  // height with layoutSubviews will work properly
  CGFloat preferredWidth = [UIScreen mainScreen].bounds.size.width -
                           self.labelsCommonSidePadding.constant * 2;
  self.nameLabel.preferredMaxLayoutWidth = preferredWidth;
  self.jobAndCompanyLabel.preferredMaxLayoutWidth = preferredWidth;
}

@end
