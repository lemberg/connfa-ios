
#import <UIKit/UIKit.h>
#import "DCSpeaker.h"

@interface DCSpeakerCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UIImageView* pictureImg;
@property(nonatomic, weak) IBOutlet UILabel* nameLbl;
@property(nonatomic, weak) IBOutlet UILabel* positionTitleLbl;
@property(nonatomic, weak) IBOutlet UIView* separator;

+ (float)cellHeight;

- (void)initData:(DCSpeaker*)speaker;

@end
