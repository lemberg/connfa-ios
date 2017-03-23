
#import "DCAppSignMenuCell.h"
#import "DCConstants.h"
#import "DCFontItem.h"

@implementation DCAppSignMenuCell

- (void)awakeFromNib {
  // Initialization code
  [super awakeFromNib];
  [self setCustomFonts];
  [self layoutIfNeeded];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setCustomFonts {

  DCFontItem *fonts = [DCConstants appFonts].firstObject;
  
  self.dateLabel.font = [UIFont fontWithName:fonts.nameFont size:self.dateLabel.font.pointSize];
  self.placeLabel.font = [UIFont fontWithName:fonts.descriptionFont size:self.placeLabel.font.pointSize];
  
}

@end
