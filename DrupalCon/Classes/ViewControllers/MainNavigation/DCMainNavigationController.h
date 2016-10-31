
#import <UIKit/UIKit.h>

@class DCEvent;
@interface DCMainNavigationController : UINavigationController

- (void)openEventFromFavoriteController:(DCEvent*)event;
- (void)goToSideMenuContainer:(BOOL)animated;

@end
