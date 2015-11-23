
#import "DCDayEventsController.h"
#import "DCEventCell.h"
#import "DCDayEventsDataSource.h"
#import "DCTimeRange+DC.h"
#import "DCTime+DC.h"
#import "DCType+DC.h"
#import "DCSpeaker+DC.h"
#import "DCLevel+DC.h"
#import "DCEventDetailViewController.h"
#import "DCLimitedNavigationController.h"
#import "DCAppFacade.h"
#import "DCTrack+DC.h"
#import "DCInfoEventCell.h"
#import "DCFavoriteEventsDataSource.h"
@interface DCDayEventsController ()<DCEventCellProtocol,
                                    DCDayEventSourceDelegate>

@property(nonatomic, weak) IBOutlet UILabel* noItemsLabel;
@property(nonatomic, weak) IBOutlet UIImageView* noItemsImageView;

@property(nonatomic, strong) NSString* stubMessage;
@property(nonatomic, strong) UIImage* stubImage;

@property(nonatomic) DCEventDataSource* eventsDataSource;

@property(nonatomic, strong) DCEventCell* cellPrototype;
@property(weak, nonatomic)
    IBOutlet UIActivityIndicatorView* activityIndicatorView;

@end

@implementation DCDayEventsController

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
  [super viewDidLoad];

  if (!self.stubMessage && !self.stubImage) {
    // this controller is not Stub controller and contains events
    [self registerCells];
    [self initDataSource];

    self.cellPrototype = [self.tableView
        dequeueReusableCellWithIdentifier:NSStringFromClass(
                                              [DCEventCell class])];
  } else {
    // this controller does not have events and will show stub Message or Image
    self.tableView.dataSource = nil;
    self.tableView.hidden = YES;

    self.noItemsLabel.hidden = !self.stubMessage;
    self.noItemsImageView.hidden = !self.stubImage;
    [self.activityIndicatorView stopAnimating];
    
    if (self.stubMessage) {
      self.noItemsLabel.text = self.stubMessage;
    } else if (self.stubImage) {
      self.noItemsImageView.image = self.stubImage;
    }
  }
}

- (void)dealloc {
  self.stubMessage = nil;
  self.stubImage = nil;

  self.cellPrototype = nil;
}

- (void)initAsStubControllerWithString:(NSString*)noEventMessage {
  self.stubMessage = noEventMessage;
}

- (void)initAsStubControllerWithImage:(UIImage*)noEventsImage {
  self.stubImage = noEventsImage;
}

- (void)updateEvents {
  [self.eventsDataSource reloadEvents];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)registerCells {
  NSString* className = NSStringFromClass([DCEventCell class]);
  [self.tableView registerNib:[UINib nibWithNibName:className bundle:nil]
       forCellReuseIdentifier:className];
}

- (void)initDataSource {
  self.eventsDataSource = [self dayEventsDataSource];
  self.eventsDataSource.delegate = self;
  __weak typeof(self) weakSelf = self;
  [self.eventsDataSource
      setPrepareBlockForTableView:^UITableViewCell*(UITableView* tableView,
                                                    NSIndexPath* indexPath) {
        NSString* cellIdentifier = NSStringFromClass([DCEventCell class]);
        DCEventCell* cell = (DCEventCell*)
            [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        DCEvent* event =
            [weakSelf.eventsDataSource eventForIndexPath:indexPath];
        NSInteger eventsCountInSection =
            [weakSelf.eventsDataSource tableView:tableView
                           numberOfRowsInSection:indexPath.section];
        cell.isLastCellInSection =
            (indexPath.row == eventsCountInSection - 1) ? YES : NO;
        cell.isFirstCellInSection = !indexPath.row;

        [cell initData:event delegate:weakSelf];
        // Some conditions for favorite events
        NSString* titleForNextSection = [weakSelf.eventsDataSource
            titleForSectionAtIdexPath:indexPath.section + 1];
        cell.separatorCellView.hidden =
            (titleForNextSection && cell.isLastCellInSection) ? YES : NO;
        if ([weakSelf.eventsStrategy leftSectionContainerColor]) {
          cell.leftSectionContainerView.backgroundColor =
              [weakSelf.eventsStrategy leftSectionContainerColor];
        }

        cell.eventTitleLabel.textColor = [UIColor blackColor];
        if ([event.favorite boolValue] &&
            [weakSelf.eventsStrategy favoriteTextColor]) {
          cell.eventTitleLabel.textColor =
              [weakSelf.eventsStrategy favoriteTextColor];
        }

        return cell;
      }];
}

- (DCEventDataSource*)dayEventsDataSource {
  if (self.eventsStrategy.strategy == EDCEeventStrategyFavorites) {
    return [[DCFavoriteEventsDataSource alloc]
        initWithTableView:self.tableView
            eventStrategy:self.eventsStrategy
                     date:self.date];
  }
  return [[DCDayEventsDataSource alloc] initWithTableView:self.tableView
                                            eventStrategy:self.eventsStrategy
                                                     date:self.date];
}

- (void)didSelectCell:(DCEventCell*)eventCell {
  NSIndexPath* cellIndexPath = [self.tableView indexPathForCell:eventCell];
  DCEvent* selectedEvent =
      [self.eventsDataSource eventForIndexPath:cellIndexPath];
  [self.parentProgramController openDetailScreenForEvent:selectedEvent];
}
#pragma mark - DCEventDataSource delegate

- (void)dataSourceStartUpdateEvents:(DCEventDataSource*)dataSource {
  [self.activityIndicatorView startAnimating];
}

- (void)dataSourceEndUpdateEvents:(DCEventDataSource*)dataSource {
  [self.activityIndicatorView stopAnimating];
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  DCEvent* event = [self.eventsDataSource eventForIndexPath:indexPath];
  self.cellPrototype.isFirstCellInSection = !indexPath.row;
  [self.cellPrototype initData:event delegate:self];

  return [self.cellPrototype getHeightForEvent:event
                              isFirstInSection:!indexPath.row];
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForHeaderInSection:(NSInteger)section {
  return [self.eventsDataSource titleForSectionAtIdexPath:section] ? 30 : 0.;
}

- (UIView*)tableView:(UITableView*)tableView
    viewForHeaderInSection:(NSInteger)section {
  DCInfoEventCell* headerViewCell = (DCInfoEventCell*)[tableView
      dequeueReusableCellWithIdentifier:NSStringFromClass(
                                            [DCInfoEventCell class])];

  NSString* title = [self.eventsDataSource titleForSectionAtIdexPath:section];
  if (title) {
    headerViewCell.titleLabel.text = title;
    return [headerViewCell contentView];
  }

  UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.0)];
  v.backgroundColor = [UIColor whiteColor];
  return v;
}

@end
