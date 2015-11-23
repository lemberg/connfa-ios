
#import "DCProgramViewController.h"
#import "DCMainProxy+Additions.h"
#import "NSDate+DC.h"
#import "DCDayEventsController.h"
#import "DCEventDetailViewController.h"
#import "DCLimitedNavigationController.h"
#import "DCAppFacade.h"
#import "NSCalendar+DC.h"

@interface DCProgramViewController ()

@property(nonatomic, strong) UIPageViewController* pageViewController;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;
@property(weak, nonatomic) IBOutlet UIButton* nextDayButton;
@property(weak, nonatomic) IBOutlet UIButton* previousDayButton;
@property(nonatomic, strong) IBOutlet UILabel* dateLabel;

@property(weak, nonatomic) IBOutlet UIView* dayContainerView;
@property(nonatomic, strong) NSArray* viewControllers;
@property(nonatomic, strong) NSArray* days;
@property(nonatomic) NSInteger currentDayIndex;
@property(nonatomic, strong)
    NSDate* currentPageDate;  // used to set current Date after filtering
@property(nonatomic) __block DCMainProxyState previousState;
@end

@implementation DCProgramViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self arrangeNavigationBar];

  self.currentDayIndex = 0;
  self.currentPageDate = nil;
  self.dayContainerView.backgroundColor =
      [DCAppConfiguration navigationBarColor];

  [self.activityIndicator startAnimating];
  
  [[DCMainProxy sharedProxy]
      setDataReadyCallback:^(DCMainProxyState mainProxyState) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSLog(@"Data ready callback %d", mainProxyState);
          if (!self.previousState) {
            [self reloadData];
            self.previousState = mainProxyState;
          } else if (mainProxyState == DCMainProxyStateDataUpdated) {
            [self reloadData];
          }
          
          [self.activityIndicator stopAnimating];

        });
      }];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [self arrangePreviousAndNextDayButtons];
}

- (void)openDetailScreenForEvent:(DCEvent*)event {
  DCEventDetailViewController* detailController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"EventDetailViewController"];

  DCDayEventsController* dayController =
      self.viewControllers[self.currentDayIndex];

  [detailController setCloseCallback:^() {
    if (self.eventsStrategy.strategy == EDCEeventStrategyFavorites) {
      [dayController updateEvents];
    }
  }];

  [detailController setEvent:event];

  DCLimitedNavigationController* navContainer =
      [[DCLimitedNavigationController alloc]
          initWithRootViewController:detailController
                          completion:^{
                            [dayController setNeedsStatusBarAppearanceUpdate];

                            NSArray* newDaysArray = self.eventsStrategy.days;

                            if ([self.days isEqualToArray:newDaysArray]) {
                              // reload just current Day controller
                              [dayController.tableView reloadData];
                            } else {
                              // days has been changed - reload all days. It's a
                              // heavy operation!
                              [self reloadData];
                            }

                          }];

  [[DCAppFacade shared]
          .mainNavigationController presentViewController:navContainer
                                                 animated:YES
                                               completion:nil];
}

#pragma mark - Private

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)arrangePreviousAndNextDayButtons {
  NSMutableArray* buttons = [[NSMutableArray alloc] init];
  for (UIControl* view in self.navigationController.navigationBar.subviews) {
    if ([view isKindOfClass:[UIControl class]]) {  // navigation bar buttons
                                                   // search
      [buttons addObject:view];
    }
  }

  if (buttons.count >= 2) {
    UIView* leftButton =
        [buttons sortedArrayUsingComparator:^NSComparisonResult(id obj1,
                                                                id obj2) {
          UIControl* button1 = obj1;
          UIControl* button2 = obj2;

          if (button1.frame.origin.x < button2.frame.origin.x)
            return NSOrderedAscending;
          else if (button1.frame.origin.x > button2.frame.origin.x)
            return NSOrderedDescending;
          else
            return NSOrderedSame;
        }].firstObject;
    float padding = leftButton.frame.origin.x;

    self.previousDayButton.contentEdgeInsets =
        UIEdgeInsetsMake(0, padding, 0, 0);
    self.nextDayButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, padding);
  }
}

- (void)arrangeNavigationBar {
  [super arrangeNavigationBar];

  [self setFilterButton];
}

- (NSUInteger)getCurrentDayIndex:(NSDate*)neededDate {
  NSDateComponents* neededDateComponents = [
      [NSCalendar currentGregorianCalendar]
      components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
        fromDate:neededDate];
  NSInteger neededDay = [neededDateComponents day];
  NSInteger neededMonth = [neededDateComponents month];
  NSInteger neededYear = [neededDateComponents year];

  for (NSDate* iteratedDay in self.days) {
    NSDateComponents* components = [[NSCalendar currentGregorianCalendar]
        components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
          fromDate:iteratedDay];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];

    if ((neededYear == year) && (neededMonth == month) && (neededDay == day))
      return [self.days indexOfObject:iteratedDay];
    else {
      if (iteratedDay.timeIntervalSince1970 > neededDate.timeIntervalSince1970)
        return [self.days indexOfObject:iteratedDay];
    }
  }

  return self.days.count ? self.days.count - 1 : 0;
}

- (void)reloadData {
  self.days = self.eventsStrategy.days.count
                  ? [[NSArray alloc] initWithArray:[_eventsStrategy days]]
                  : nil;

  // set current page Index to set proper Date after filtering
  if (self.currentPageDate) {
    self.currentDayIndex = [self getCurrentDayIndex:self.currentPageDate];
    self.currentPageDate = nil;
  }

  self.viewControllers = [self createViewControllersForDays:self.days];
  [self updatePageController];
  [self updateButtonsVisibility];
}

- (void)updatePageController {
  [self.pageViewController
      setViewControllers:@[ self.viewControllers[self.currentDayIndex] ]
               direction:UIPageViewControllerNavigationDirectionForward
                animated:NO
              completion:nil];

  [self displayDateForDay:self.currentDayIndex];
}

- (void)displayDateForDay:(NSInteger)day {
  // change UILabel text animatically
  CATransition* animation = [CATransition animation];
  animation.timingFunction = [CAMediaTimingFunction
      functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  animation.type = kCATransitionFade;
  animation.duration = 0.6;
  [self.dateLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];

  NSDate* date = _days[day];
  self.dateLabel.text =
      date ? [DCDateHelper convertDate:date toDefaultTimeFormat:@"EEEE dd"]
           : nil;
}

- (NSArray*)createViewControllersForDays:(NSArray*)aDays {
  if (aDays.count) {
    NSMutableArray* controllers =
        [[NSMutableArray alloc] initWithCapacity:aDays.count];
    NSUInteger currentDatePageIndex = 0;
    NSInteger daysCount = [aDays count];
    if (daysCount && self.currentDayIndex >= daysCount) {
      self.currentDayIndex = 0;
    }
    for (NSDate* date in self.days) {
      if ([NSDate dc_isDateInToday:date])
        self.currentDayIndex = currentDatePageIndex;

      DCDayEventsController* dayEventsController = [self.storyboard
          instantiateViewControllerWithIdentifier:
              NSStringFromClass([DCDayEventsController class])];
      dayEventsController.parentProgramController = self;
      dayEventsController.date = date;
      dayEventsController.eventsStrategy = self.eventsStrategy;

      [controllers addObject:dayEventsController];
      currentDatePageIndex++;
    }
    return controllers;
  } else  // make stub controller with no items
  {
    DCDayEventsController* dayEventsController =
        [self.storyboard instantiateViewControllerWithIdentifier:
                             NSStringFromClass([DCDayEventsController class])];

    if (self.eventsStrategy.strategy == EDCEeventStrategyFavorites)
      [dayEventsController
          initAsStubControllerWithImage:[UIImage imageNamed:@"empty_icon"]];
    else
      [dayEventsController
          initAsStubControllerWithString:@"No Matching Events"];

    return @[ dayEventsController ];
  }
}

- (void)updateButtonsVisibility {
  _previousDayButton.hidden = (self.currentDayIndex == 0 ? YES : NO);
  _nextDayButton.hidden =
      (self.currentDayIndex == (_days.count - 1) || !self.days.count ? YES
                                                                     : NO);
}

- (void)setFilterButton {
  if (![self.eventsStrategy isEnableFilter]) {
    return;
  }
  UIImage* filterImage = [UIImage
      imageNamed:[[DCMainProxy sharedProxy] isFilterCleared] ? @"filter-"
                                                             : @"filter+"];
  UIBarButtonItem* filterButton =
      [[UIBarButtonItem alloc] initWithImage:filterImage
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(onFilterButtonClick)];

  self.navigationItem.rightBarButtonItem = filterButton;
}

#pragma mark - User actions

- (void)onFilterButtonClick {
  UINavigationController* filterController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"EventFilterviewController"];
  [(DCFilterViewController*)filterController.viewControllers[0]
      setDelegate:self];
  [self presentViewController:filterController animated:YES completion:nil];
}

- (void)filterControllerWillDismiss:(BOOL)cancel {
  if (!cancel) {
    self.pageViewController.dataSource = nil;
    self.currentPageDate = self.days[self.currentDayIndex];

    [self setFilterButton];
    [self reloadData];

    self.pageViewController.dataSource = self;
    [self setCurrentDayControllerAtIndex:self.currentDayIndex];
  }
}

- (void)updateControllersaToFilterValues {
  for (UIViewController* viewController in self.viewControllers) {
    if ([viewController
            conformsToProtocol:@protocol(DCUpdateDayEventProtocol)]) {
      [(id<DCUpdateDayEventProtocol>)viewController updateEvents];
    }
    break;
  }
}

- (IBAction)previousDayClicked:(id)sender {
  if (self.currentDayIndex == 0)
    return;

  self.currentDayIndex--;

  [self updateButtonsVisibility];
  [self displayDateForDay:self.currentDayIndex];
  [self.pageViewController
      setViewControllers:@[ self.viewControllers[self.currentDayIndex] ]
               direction:UIPageViewControllerNavigationDirectionReverse
                animated:YES
              completion:nil];
}

- (void)setCurrentDayControllerAtIndex:(NSUInteger)pageIndex {
  [self updateButtonsVisibility];
  [self displayDateForDay:pageIndex];
  [self.pageViewController
      setViewControllers:@[ self.viewControllers[pageIndex] ]
               direction:UIPageViewControllerNavigationDirectionReverse
                animated:NO
              completion:nil];
}

- (IBAction)nextDayClicked:(id)sender {
  if (self.currentDayIndex >= self.days.count - 1)
    return;

  self.currentDayIndex++;

  [self updateButtonsVisibility];
  [self displayDateForDay:self.currentDayIndex];
  [self.pageViewController
      setViewControllers:@[ self.viewControllers[self.currentDayIndex] ]
               direction:UIPageViewControllerNavigationDirectionForward
                animated:YES
              completion:nil];
}

#pragma mark - UIPageViewController delegate and datasource

- (UIViewController*)pageViewController:
                         (UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController {
  NSUInteger index =
      [self.days indexOfObject:((DCDayEventsController*)viewController).date];

  if ((index == 0) || (index == NSNotFound)) {
    return nil;
  }

  index--;
  return self.viewControllers[index];
}

- (UIViewController*)pageViewController:
                         (UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController {
  if (!self.days.count)
    return nil;

  NSUInteger index =
      [self.days indexOfObject:((DCDayEventsController*)viewController).date];
  if (index == NSNotFound) {
    return nil;
  }

  index++;
  if (index == _days.count) {
    return nil;
  }
  return self.viewControllers[index];
}

- (void)pageViewController:(UIPageViewController*)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray*)previousViewControllers
       transitionCompleted:(BOOL)completed {
  if (completed) {
    NSUInteger currentIndex = [self.days
        indexOfObject:
            [(DCDayEventsController*)
                    [self.pageViewController.viewControllers lastObject] date]];
    self.currentDayIndex = currentIndex;
    [self displayDateForDay:self.currentDayIndex];
    [self updateButtonsVisibility];
  }
}

#pragma mark - UIStoryboardSegue delegate

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"EmbeddedDaysPageVC"]) {
    self.pageViewController = [segue destinationViewController];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
  }
}

@end
