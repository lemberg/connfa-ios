
#import <UIKit/UIKit.h>
#import "DCMainProxy.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

typedef enum {
  EBaseViewControllerNatigatorBarStyleNormal,
  EBaseViewControllerNatigatorBarStyleTransparrent
} EBaseViewControllerNatigatorBarStyle;

@interface DCBaseViewController : UIViewController

@property(nonatomic) EBaseViewControllerNatigatorBarStyle navigatorBarStyle;

- (void)arrangeNavigationBar;
- (void)registerScreenLoadAtGA:(NSString*)message;
- (void)updateLabel:(UILabel *)label withFontName:(NSString *)fontName;
@end
