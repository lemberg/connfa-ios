
#import "DCAppSignMenuCell.h"
#import "DCConstants.h"

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
  
  NSDictionary *fonts = [[DCConstants appFonts] objectForKey:kFontMenuItemsScreen];
  self.dateLabel.font = [fonts objectForKey:kFontName];
  self.placeLabel.font = [fonts objectForKey:kFontDescription];
  
}

@end
