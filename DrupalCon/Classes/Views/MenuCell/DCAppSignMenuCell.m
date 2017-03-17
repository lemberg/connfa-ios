
#import "DCAppSignMenuCell.h"

@implementation DCAppSignMenuCell

- (void)awakeFromNib {
  // Initialization code
  [super awakeFromNib];
  self.dateLabel.text = [DCAppConfiguration eventTime];
  self.placeLabel.text = [DCAppConfiguration eventPlace];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

@end
