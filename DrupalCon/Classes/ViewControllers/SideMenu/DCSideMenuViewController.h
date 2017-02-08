
#import <UIKit/UIKit.h>
#import "MFSideMenuContainerViewController.h"

@class DCEvent;


@interface DCSideMenuViewController : UIViewController<UITableViewDelegate>

@property(nonatomic, weak) MFSideMenuContainerViewController* sideMenuContainer;

- (void)openEventFromFavorite:(DCEvent*)event;

@end
