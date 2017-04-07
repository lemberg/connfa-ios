
#import "DCBaseViewController.h"
#import "DCEventStrategy.h"
#import "DCProgramViewController.h"
#import "DCEventDataSource.h"

typedef enum : NSUInteger {
  DCStateNormal,
  DCStateEmpty,
} DCState;

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
@property(nonatomic) DCEventDataSource* eventsDataSource;


@property(nonatomic, weak) DCProgramViewController* parentProgramController;
@property(nonatomic, strong) DCEventStrategy* eventsStrategy;
@property(nonatomic) DCState state;

- (void)updateEvents;
//- (void)initAsStubControllerWithString:(NSString*)noEventMessage;
//- (void)initAsStubControllerWithImage:(UIImage*)noEventsImage;

@end


