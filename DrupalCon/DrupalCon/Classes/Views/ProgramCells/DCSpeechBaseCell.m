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

#import "DCSpeechBaseCell.h"

@implementation DCSpeechBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)awakeFromNib {
  // Initialization code
  self.favoriteButton.exclusiveTouch = YES;
  UIView* bgColorView = [[UIView alloc] init];
  float value = 238. / 255.;
  bgColorView.backgroundColor =
      [UIColor colorWithRed:value green:value blue:value alpha:1.0];
  [self setSelectedBackgroundView:bgColorView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

#pragma mark -

- (void)setTrack:(NSString*)trackStr {
  if (trackStr.length == 0) {
    self.trackBlockNameLabel.hidden = YES;
    self.trackLabel.hidden = YES;
  } else {
    self.trackBlockNameLabel.hidden = NO;
    self.trackLabel.hidden = NO;
    self.trackLabel.text = trackStr;
  }
}

- (void)setLevel:(NSString*)levelStr {
  if (levelStr.length == 0) {
    self.levelBlockNameLabel.hidden = YES;
    self.experienceLevelLabel.hidden = YES;
  } else {
    self.levelBlockNameLabel.hidden = NO;
    self.experienceLevelLabel.hidden = NO;
    self.experienceLevelLabel.text = levelStr;
  }
}

- (void)setSpeakers:(NSString*)speakers {
  if (speakers.length == 0) {
    self.speakerBlockNameLabel.hidden = YES;
    self.speakerLabel.hidden = YES;
  } else {
    self.speakerBlockNameLabel.hidden = NO;
    self.speakerLabel.hidden = NO;
    self.speakerLabel.text = speakers;
  }
}

#pragma mark -

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
  self.favoriteBtnCallback(self, fvBtn.isSelected);
}

@end
