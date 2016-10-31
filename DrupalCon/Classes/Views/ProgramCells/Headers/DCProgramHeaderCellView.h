
#import <UIKit/UIKit.h>

@interface DCProgramHeaderCellView : UITableViewCell
@property(nonatomic, weak) IBOutlet UIImageView* leftImageView;
@property(nonatomic, weak) IBOutlet UILabel* startLabel;
@property(nonatomic, weak) IBOutlet UILabel* endLabel;
@property(weak, nonatomic) IBOutlet UILabel* dateLabel;
@property(weak, nonatomic) IBOutlet UILabel* toLabel;

- (void)hideTimeSection:(BOOL)isHide;

@end
