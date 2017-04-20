
#import "DCBaseViewController.h"
#import "DCEventStrategy.h"
#import "DCFilterViewController.h"
#import "DCSchedulesListTableViewController.h"


/**
 *  @class DCProgramViewController is the container(UIPageViewController) 
 * for each days of events.
 *
 */

@interface DCProgramViewController
    : DCBaseViewController<UIPageViewControllerDataSource,
                           UIPageViewControllerDelegate,
                           UITextFieldDelegate,
                           DCFilterViewControllerDelegate,
                           ScheduleListDelegate>
/**
 *  DCEventStrategy decides what contents should be dipslayed for  event types
 */
@property(nonatomic, strong) DCEventStrategy* eventsStrategy;

- (void)openDetailScreenForEvent:(DCEvent*)event;

@end
