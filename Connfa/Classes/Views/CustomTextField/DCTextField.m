
#import "DCTextField.h"

@implementation DCTextField

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
  }
  return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder {
  self = [super initWithCoder:aDecoder];
  self.layer.borderWidth = 2.5;
  self.layer.borderColor = [[UIColor whiteColor] CGColor];
  return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
  return CGRectMake(bounds.origin.x, bounds.origin.y - 2, bounds.size.width,
                    bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  return [self textRectForBounds:bounds];
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
