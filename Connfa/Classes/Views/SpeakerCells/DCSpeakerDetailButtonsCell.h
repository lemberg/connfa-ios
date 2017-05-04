
#import <UIKit/UIKit.h>
#import "DCSpeaker+CoreDataProperties.h"

@interface DCSpeakerDetailButtonsCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UIButton* webButton;
@property(nonatomic, weak) IBOutlet UIButton* twitterButton;

@property(nonatomic, weak)
    IBOutlet NSLayoutConstraint* webButtonLeftPadding;
@property(nonatomic, weak)
    IBOutlet NSLayoutConstraint* twitterButtonBottomPadding;

@property (weak, nonatomic) IBOutlet UIView *separatorView;

- (void)initData:(DCSpeaker*)speaker;

@end
