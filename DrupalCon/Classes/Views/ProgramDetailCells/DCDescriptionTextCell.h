
#import <UIKit/UIKit.h>
@interface DCDescriptionTextCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UIWebView* descriptionWebView;
@property(nonatomic, weak) IBOutlet UITextView* descriptionTxt;
+ (float)cellHeightForText:(NSString*)text;

@end
