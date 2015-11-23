
#import <UIKit/UIKit.h>

typedef enum {
  VerticalAlignmentTop = 0,  // default
  VerticalAlignmentMiddle,
  VerticalAlignmentBottom,
} VerticalAlignment;

@interface DCLabel : UILabel
@property(nonatomic, readwrite) VerticalAlignment verticalAlignment;
@end
