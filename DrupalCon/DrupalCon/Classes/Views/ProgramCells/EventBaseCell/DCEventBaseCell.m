//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in
//   all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE
//  SOFTWARE.
//

#import "DCEventBaseCell.h"
#import "DCLabel.h"

@implementation DCEventBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
    [self connectOutletsWithCurrentClass];
    [self setSelectedBackground];
  }
  return self;
}

- (void)setSelectedBackground {
  UIView* bgColorView = [[UIView alloc] init];
  float value = 238. / 255.;
  bgColorView.backgroundColor =
      [UIColor colorWithRed:value green:value blue:value alpha:1.0];
  [self setSelectedBackgroundView:bgColorView];
}
- (void)connectOutletsWithCurrentClass {
  // FIXME: In xib file only create a view container
  UINib* nib = [UINib nibWithNibName:@"DCEventBaseCell" bundle:nil];
  UITableViewCell* cellContainer =
      [[nib instantiateWithOwner:self options:nil] firstObject];
  // Remove gestures from contentView
  while (cellContainer.contentView.gestureRecognizers.count) {
    [cellContainer.contentView
        removeGestureRecognizer:[cellContainer.contentView.gestureRecognizers
                                    objectAtIndex:0]];
  }
  [self.contentView addSubview:cellContainer.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)removeLabelContent {
  self.title.text = @"";
  self.leftBlockTitle.text = @"";
  self.middleBlockTitle.text = @"";
  self.rightBlockTitle.text = @"";

  self.leftBlockContent.text = @"";
  self.middleBlockContent.text = @"";
  self.rightBlockContent.text = @"";
}

- (void)setValuesForCell:(NSDictionary*)values {
  [self removeLabelContent];

  self.title.text = values[kHeaderTitle];
  self.leftBlockTitle.text = values[kLeftBlockTitle];
  self.middleBlockTitle.text = values[kMiddleBlockTitle];
  self.rightBlockTitle.text = values[kRightBlockTitle];

  self.leftBlockContent.text = values[kLeftBlockContent];
  self.middleBlockContent.text = values[kMiddleBlockContent];
  self.rightBlockContent.text = values[kRightBlockContent];
}
- (void)favoriteButtonDidSelected:(FavoriteButtonPressedCallback)callback {
  self.favoriteBtnCallback = callback;
}

- (IBAction)favoriteBtnPress:(id)sender {
  UIButton* fvBtn = (UIButton*)sender;
  if ([sender isSelected]) {
    fvBtn.selected = NO;
  } else {
    fvBtn.selected = YES;
  }
  if (self.favoriteBtnCallback) {
    self.favoriteBtnCallback(self, fvBtn.isSelected);
  }
}
@end
