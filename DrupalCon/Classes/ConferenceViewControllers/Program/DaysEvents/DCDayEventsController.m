
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
#import "DCMainProxy+Additions.h"

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

@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noEventsImageView_heightConstraint;
@property (nonatomic) CGFloat noEventsImageViewDefaultHeight;

@end

@implementation DCDayEventsController

#pragma mark - Life cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.noEventsImageViewDefaultHeight = 100.0;
  
  [self configureState];
}

- (void)dealloc {
  self.stubMessage = nil;
  self.stubImage = nil;
  
  self.cellPrototype = nil;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
}

#pragma mark - Public

- (void)updateEvents {
  [self.eventsDataSource reloadEvents];
}

#pragma mark - Private

- (void)configureState {
  if (self.state == DCStateNormal) {
    self.noDataView.hidden = YES;
    [self registerCells];
    [self initDataSource];
    self.cellPrototype = [self.tableView
                          dequeueReusableCellWithIdentifier:NSStringFromClass([DCEventCell class])];
  } else {
    [self configureEmptyView];
  }
}

- (void)configureEmptyView {
  self.noDataView.hidden = NO;
  BOOL isFilterEnabled = ![[DCMainProxy sharedProxy] isFilterCleared];
  if (self.eventsStrategy.strategy != EDCEeventStrategyFavorites)
    self.noEventsImageView_heightConstraint.constant =  isFilterEnabled ? 0 : self.noEventsImageViewDefaultHeight;
 
  switch (self.eventsStrategy.strategy) {
    case EDCEventStrategyPrograms: {
      self.stubImage = [UIImage imageNamed:@"ic_no_sessions"];
      self.stubMessage = isFilterEnabled ? @"No Matching Events" : @"Currently there are no sessions";
    }
      break;
    case EDCEeventStrategyFavorites: {
      self.stubImage = [UIImage imageNamed:@"ic_no_my_schedule"];
      self.stubMessage = @"Your schedule is empty.\nPlease add some events";
    }
      break;
    case EDCEventStrategyBofs: {
      self.stubImage = [UIImage imageNamed:@"ic_no_bofs"];
      self.stubMessage = isFilterEnabled ? @"No Matching BoFs" : @"Currently there are no BoFs";
    }
      break;
    case EDCEventStrategySocialEvents: {
      self.stubImage = [UIImage imageNamed:@"ic_no_social_events"];
      self.stubMessage = isFilterEnabled ? @"No Matching social events" : @"Currently there are no social events";
    }
      break;
  }
  
  self.tableView.dataSource = nil;
  self.tableView.hidden = YES;
  [self.activityIndicatorView stopAnimating];
  self.noItemsLabel.text = self.stubMessage;
  self.noItemsImageView.image = self.stubImage;
  [self.noItemsImageView layoutIfNeeded];
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
//        NSString* titleForNextSection = [weakSelf.eventsDataSource
//            titleForSectionAtIdexPath:indexPath.section + 1];
//        cell.separatorCellView.hidden =
//            (titleForNextSection && cell.isLastCellInSection) ? YES : NO;
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
