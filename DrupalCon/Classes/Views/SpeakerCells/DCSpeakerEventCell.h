
#import <UIKit/UIKit.h>
#import "DCEvent.h"

@interface DCSpeakerEventCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel* eventNameLabel;
@property(nonatomic, weak) IBOutlet UILabel* eventTimeLabel;
@property(nonatomic, weak) IBOutlet UILabel* eventTrackLabel;
@property(nonatomic, weak) IBOutlet UILabel* eventLevelLabel;
@property(nonatomic, weak) IBOutlet UIImageView* experienceIcon;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint* labelsCommonSidePadding;

@property(nonatomic, weak) IBOutlet UIView* separator;

- (void)initData:(DCEvent*)event;

@end
