
#import "DCBaseViewController.h"
#import "DCEventStrategy.h"
#import "DCProgramViewController.h"

@protocol DCUpdateDayEventProtocol<NSObject>

- (void)updateEvents;

@end

/**
 *  @class DCDayEventsController is container for each event day
 *
 */
@interface DCDayEventsController
    : DCBaseViewController<DCUpdateDayEventProtocol>

@property(nonatomic) IBOutlet UITableView* tableView;

/**
 *  Day date for current events
 */
@property(nonatomic, strong) NSDate* date;


@property(nonatomic, weak) DCProgramViewController* parentProgramController;
@property(nonatomic, strong) DCEventStrategy* eventsStrategy;

- (void)updateEvents;
- (void)initAsStubControllerWithString:(NSString*)noEventMessage;
- (void)initAsStubControllerWithImage:(UIImage*)noEventsImage;

@end


