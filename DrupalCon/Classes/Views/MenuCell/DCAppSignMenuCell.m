
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

  self.dateLabel.font = [UIFont fontWithName:[[DCConstants appFonts] objectForKey:kFontName] size:self.dateLabel.font.pointSize];
  self.placeLabel.font = [UIFont fontWithName:[[DCConstants appFonts] objectForKey:kFontDescription] size:self.placeLabel.font.pointSize];
  
}

@end
