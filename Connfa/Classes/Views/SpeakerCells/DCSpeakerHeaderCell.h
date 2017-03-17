
#import <UIKit/UIKit.h>
#import "DCSpeaker.h"

@interface DCSpeakerHeaderCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UIImageView* photoImageView;
@property(nonatomic, weak) IBOutlet UILabel* nameLabel;
@property(nonatomic, weak) IBOutlet UILabel* jobAndCompanyLabel;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint* labelsCommonSidePadding;

- (void)initData:(DCSpeaker*)speaker;

@end
