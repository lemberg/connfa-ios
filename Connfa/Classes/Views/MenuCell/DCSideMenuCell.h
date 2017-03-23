
#import <UIKit/UIKit.h>

@interface DCSideMenuCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel* captionLabel;
@property(nonatomic, weak) IBOutlet UIImageView* leftImageView;

@property(nonatomic, strong) IBOutlet UIView* selectedBackground;

@end
