
#import <UIKit/UIKit.h>
#import "DCEvent.h"

@interface DCEventDetailHeaderCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel* titleLabel;
@property(nonatomic, weak) IBOutlet UILabel* dateAndPlaceLabel;
@property(nonatomic, weak) IBOutlet UILabel* trackLabel;
@property(nonatomic, weak) IBOutlet UILabel* experienceLabel;
@property(nonatomic, weak) IBOutlet UIImageView* experienceIcon;
@property(nonatomic, weak) IBOutlet UIView* TrackAndLevelView;
@property(weak, nonatomic) IBOutlet UIView* eventDetailContainerView;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint* trackAndLevelViewHeight;

- (void)initData:(DCEvent*)event;

@end
