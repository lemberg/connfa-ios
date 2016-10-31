
#import <UIKit/UIKit.h>
#import "MFSideMenuContainerViewController.h"

@class DCEvent;

#define kMenuItemTitle @"MenuItemTitle"
#define kMenuItemIcon @"MenuItemIcon"
#define kMenuItemSelectedIcon @"MenuItemSelectedIcon"
#define kMenuItemControllerId @"MenuItemControllerId"
#define kMenuType @"MenuType"
@interface DCSideMenuViewController : UIViewController<UITableViewDelegate>

@property(nonatomic, weak) MFSideMenuContainerViewController* sideMenuContainer;

- (void)openEventFromFavorite:(DCEvent*)event;

@end
