
#import "DCSpeakerDetailButtonsCell.h"

@implementation DCSpeakerDetailButtonsCell

- (void)initData:(DCSpeaker*)speaker {
  // hide unused buttons

  self.twitterButton.hidden = !speaker.twitterName.length;
  self.webButton.hidden = !speaker.webSite.length;

  if (self.twitterButton.hidden) {
    [self.twitterButton setImage:[UIImage new] forState:UIControlStateNormal];
    self.webButtonLeftPadding.constant = 0;

  }

  // if there is no description below, remove bottom padding
//  if (speaker.characteristic.length) {
//    self.twitterButtonBottomPadding.constant = 0;
//  }
}

@end
