
#import <UIKit/UIKit.h>
#import "DCSpeaker.h"

@interface DCSpeakerDetailButtonsCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UIButton* webButton;
@property(nonatomic, weak) IBOutlet UIButton* twitterButton;

@property(nonatomic, weak)
    IBOutlet NSLayoutConstraint* twitterButtonLeftPadding;
@property(nonatomic, weak)
    IBOutlet NSLayoutConstraint* twitterButtonBottomPadding;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint* twitterButtonWidth;

- (void)initData:(DCSpeaker*)speaker;

@end
