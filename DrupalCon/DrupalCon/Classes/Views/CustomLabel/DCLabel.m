/**********************************************************************************
 *                                                                           
 *  The MIT License (MIT)
 *  Copyright (c) 2015 Lemberg Solutions Limited
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the 
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *   The above copyright notice and this permission notice shall be included in
 *   all  copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM,  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 *  IN THE SOFTWARE.
 *
 *                                                                           
 *****************************************************************************/



#import "DCLabel.h"

@implementation DCLabel
@synthesize verticalAlignment = _verticalAlignment;
- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (!self)
    return nil;

  // set inital value via IVAR so the setter isn't called
  _verticalAlignment = VerticalAlignmentTop;

  return self;
}

- (VerticalAlignment)verticalAlignment {
  return _verticalAlignment;
}

- (void)setVerticalAlignment:(VerticalAlignment)value {
  _verticalAlignment = value;
  [self setNeedsDisplay];
}

// align text block according to vertical alignment settings
- (CGRect)textRectForBounds:(CGRect)bounds
     limitedToNumberOfLines:(NSInteger)numberOfLines {
  CGRect rect =
      [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
  CGRect result;
  switch (_verticalAlignment) {
    case VerticalAlignmentTop:
      result = CGRectMake(bounds.origin.x, bounds.origin.y, rect.size.width,
                          rect.size.height);
      break;

    case VerticalAlignmentMiddle:
      result = CGRectMake(
          bounds.origin.x,
          bounds.origin.y + (bounds.size.height - rect.size.height) / 2,
          rect.size.width, rect.size.height);
      break;

    case VerticalAlignmentBottom:
      result =
          CGRectMake(bounds.origin.x,
                     bounds.origin.y + (bounds.size.height - rect.size.height),
                     rect.size.width, rect.size.height);
      break;

    default:
      result = bounds;
      break;
  }
  return result;
}

- (void)drawTextInRect:(CGRect)rect {
  CGRect r =
      [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
  [super drawTextInRect:r];
}

@end
