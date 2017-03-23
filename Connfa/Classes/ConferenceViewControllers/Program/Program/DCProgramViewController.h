
#import "DCBaseViewController.h"
#import "DCEventStrategy.h"
#import "DCFilterViewController.h"

/**
 *  @class DCProgramViewController is the container(UIPageViewController) 
 * for each days of events.
 *
 */

@interface DCProgramViewController
    : DCBaseViewController<UIPageViewControllerDataSource,
                           UIPageViewControllerDelegate,
                           DCFilterViewControllerDelegate>
/**
 *  DCEventStrategy decides what contents should be dipslayed for  event types
 */
@property(nonatomic, strong) DCEventStrategy* eventsStrategy;

- (void)openDetailScreenForEvent:(DCEvent*)event;

@end
