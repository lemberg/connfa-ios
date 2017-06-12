
#import <UIKit/UIKit.h>
#import "MFSideMenuContainerViewController.h"

@class DCEvent;


@interface DCSideMenuViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) MFSideMenuContainerViewController* sideMenuContainer;

- (void)openEventFromFavorite:(DCEvent*)event;
- (void)openScheduleForSchduleId:(NSString *)scheduleId;

@end
