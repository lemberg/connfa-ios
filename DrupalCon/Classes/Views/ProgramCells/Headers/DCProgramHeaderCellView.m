
#import "DCProgramHeaderCellView.h"

@implementation DCProgramHeaderCellView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)hideTimeSection:(BOOL)isHide {
  self.startLabel.hidden = isHide;
  self.endLabel.hidden = isHide;
  self.dateLabel.hidden = isHide;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
