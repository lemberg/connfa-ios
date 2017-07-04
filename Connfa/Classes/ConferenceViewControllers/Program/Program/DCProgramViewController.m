
#import "DCProgramViewController.h"
#import "DCMainProxy+Additions.h"
#import "NSDate+DC.h"
#import "DCDayEventsController.h"
#import "DCEventDetailViewController.h"
#import "DCLimitedNavigationController.h"
#import "DCAppFacade.h"
#import "NSCalendar+DC.h"
#import "DCWebService.h"
#import "DCSharedSchedule+DC.h"
#import "DCCoreDataStore.h"
#import "DCConstants.h"
#import "NSUserDefaults+DC.h"
#import "DCAlertsManager.h"
#import <SVProgressHUD.h>

@interface DCProgramViewController (){
  NSString *titleString;
  EScheduleType selectedScheduleType;
  UIAlertAction *addFriendScheduleAction;
  UIAlertAction *okAction;
  DCSharedSchedule* selectedSchedule;
}

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

#pragma mark - Init

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  titleString = @"My Schedule";
  
  [self arrangeNavigationBar];
  [self setSchedulesTitle];
  selectedScheduleType = EMySchedule;
  
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
  [self registerScreenLoadAtGA:[NSString stringWithFormat:@"%@", self.navigationItem.title]];
  if (self.eventsStrategy.strategy == EDCEeventStrategyFavorites){
    [self showInstructionsScreen];
    [[DCMainProxy sharedProxy] updateSchedule];
  }
  
  NSString* code = [[NSUserDefaults standardUserDefaults] objectForKey:@"codeFromLink"];
  if(code){
    [self addSchedule:code];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"codeFromLink"];
  }
  if (self.eventsStrategy.strategy == EDCEeventStrategyFavorites || self.eventsStrategy.strategy == EDCEventStrategySharedSchedule){
    [self reloadData];
  }
}

#pragma mark - Public

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
  [self setMoreActionsButton];
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
  if(self.viewControllers){
    [self.pageViewController
     setViewControllers:@[ self.viewControllers[self.currentDayIndex] ]
     direction:UIPageViewControllerNavigationDirectionForward
     animated:NO
     completion:nil];
    
    [self displayDateForDay:self.currentDayIndex];
  }else {
    DCDayEventsController* dayEventsController =
    [self.storyboard instantiateViewControllerWithIdentifier:
     NSStringFromClass([DCDayEventsController class])];
    dayEventsController.eventsStrategy = self.eventsStrategy;
    dayEventsController.state = DCStateEmpty;
    
    [self.pageViewController
     setViewControllers:@[ dayEventsController ]
     direction:UIPageViewControllerNavigationDirectionForward
     animated:NO
     completion:nil];

  }
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
  self.dateLabel.text = date ? [[date dateToStringWithFormat:@"EEEE dd"] uppercaseString] : nil;
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
      dayEventsController.state = DCStateNormal;

      [controllers addObject:dayEventsController];
      currentDatePageIndex++;
    }
    return controllers;
  } else { // make stub controller with no items
    DCDayEventsController* dayEventsController =
        [self.storyboard instantiateViewControllerWithIdentifier:
                             NSStringFromClass([DCDayEventsController class])];
    dayEventsController.eventsStrategy = self.eventsStrategy;
    dayEventsController.state = DCStateEmpty;
    return @[ dayEventsController ];
  }
}

- (void)updateButtonsVisibility {
  _previousDayButton.hidden = (self.currentDayIndex == 0 ? YES : NO);
  _nextDayButton.hidden =
      (self.currentDayIndex == (_days.count - 1) || !self.days.count ? YES
                                                                     : NO);
}

-(void)setMoreActionsButton{
  if (self.eventsStrategy.strategy != EDCEeventStrategyFavorites){
    return;
  }
  UIImage* moreActionsImage = [UIImage
                          imageNamed:@"More Actions Button_white"];
  UIBarButtonItem* moreActionsButton =
  [[UIBarButtonItem alloc] initWithImage:moreActionsImage
                                   style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(onMoreActionsButtonClick)];
  
  self.navigationItem.rightBarButtonItem = moreActionsButton;
}

- (void)setSchedulesTitle{
  if (self.eventsStrategy.strategy != EDCEeventStrategyFavorites && self.eventsStrategy.strategy != EDCEventStrategySharedSchedule){
    return;
  }
  UIFont *titleFont = [UIFont fontWithName:@".SFUIText-Semibold" size:17];
  NSDictionary *userAttributes = @{NSFontAttributeName: titleFont,
                                   NSForegroundColorAttributeName: [UIColor whiteColor]};
  CGSize textSize = [titleString sizeWithAttributes:userAttributes];
  CGFloat textWidth = 200.0;
  if (textSize.width < 200) {
    textWidth = textSize.width;
  }
  
  UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, textWidth + 20, textSize.height)];
  
  UILabel* titleLabel = [self createTitleLabelWithWidth:textWidth height:textSize.height font:titleFont];
  titleLabel.center = titleView.center;
  
  NSArray* schedules = [[DCMainProxy sharedProxy] getAllSharedSchedules];
  
  if(schedules.count){
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTitle)];
    UIImageView *disclosureIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(textWidth + 14, titleLabel.frame.size.height/2 - 1, 10, 4)];
    disclosureIndicator.image = [UIImage imageNamed:@"Disclosure Indicator"];
    [titleView addGestureRecognizer:singleFingerTap];
    [titleView addSubview:disclosureIndicator];
  }
  [titleView addSubview:titleLabel];
  
  self.navigationItem.titleView = titleView;
}

-(UILabel *)createTitleLabelWithWidth:(CGFloat)width height:(CGFloat)height font:(UIFont *)font{
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
  titleLabel.font = font;
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.text = titleString;

  return titleLabel;
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

-(void)showInstructionsScreen{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if(![defaults boolForKey:@"MyScheduleTutorialShown"]) {
    [defaults setBool:true forKey:@"MyScheduleTutorialShown"];
    [self performSegueWithIdentifier:@"toTutorial" sender:self];
  }
}

-(void)showMyScheduleActions{
  
  UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  actionSheet.view.tintColor = [UIColor blackColor];
  UIAlertAction *addScheduleAction = [UIAlertAction actionWithTitle:@"Add a schedule" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self addSchedule:nil];
  }];
  UIAlertAction *shareMyScheduleAction = [UIAlertAction actionWithTitle:@"Share My Schedule" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self shareMySchedule];
  }];
  
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
  [actionSheet addAction:addScheduleAction];
  [actionSheet addAction:shareMyScheduleAction];
  [actionSheet addAction:cancelAction];
  [self presentViewController:actionSheet animated:true completion:nil];
}

-(void)showFriendScheduleActions{
  UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  actionSheet.view.tintColor = [UIColor blackColor];
  UIAlertAction *editAction = [UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self showEditAlertView];
  }];
  UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    [self showConfirmationAlertView];
  }];
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
  [actionSheet addAction:editAction];
  [actionSheet addAction:removeAction];
  [actionSheet addAction:cancelAction];
  [self presentViewController:actionSheet animated:true completion:nil];
}

-(void)addSchedule:(NSString *)code{
  if(![[DCMainProxy sharedProxy] checkReachable]){
    [DCAlertsManager showAlertControllerWithTitle:@"Internet connection is not available at this moment. Please, try later." message:nil forController:self];
    return;
  }
  UIAlertController *addScheduleAlert = [UIAlertController alertControllerWithTitle:@"Add a schedule"
                                                                            message:@"You may get this code from a person who has already shared his/her own schedule with you."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
  [addScheduleAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    textField.placeholder = @"Schedule unique code";
    textField.delegate = self;
    textField.text = code;
  }];
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
  //TODO: replace initialization
  addFriendScheduleAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                     NSString* myCode = [NSUserDefaults myScheduleCode].stringValue;
                                                     if([myCode isEqualToString:addScheduleAlert.textFields.firstObject.text]){
                                                       return;
                                                     }
                                                     NSArray* schedulesForId = [[DCMainProxy sharedProxy] getScheduleWithId:addScheduleAlert.textFields.firstObject.text];
                                                     if(!schedulesForId.count){
                                                       [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                                                       [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
                                                       [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                                                       [SVProgressHUD showWithStatus: @"Loading schedule..."];
                                                       [[DCMainProxy sharedProxy] getSchedule:addScheduleAlert.textFields.firstObject.text callback:^(BOOL success, NSDictionary* scheduleDictionary){
                                                         if(success){
                                                           [self dismissProgressHUD];
                                                           [self showAddScheduleNameAlert: scheduleDictionary];
                                                         } else {
                                                           [self dismissProgressHUD];
                                                           [DCAlertsManager showAlertControllerWithTitle:@"Schedule not found."
                                                                                                 message:@"Please check your code."
                                                                                           forController:self];
                                                         }
                                                       }];
                                                     } else {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                         DCSharedSchedule *scheduleToSwitch = schedulesForId.firstObject;
                                                         [self setScheduleName:scheduleToSwitch.name];
                                                         [self setScheduleType:EFriendSchedule andSchedule:scheduleToSwitch];
                                                         [DCAlertsManager showAlertControllerWithTitle:nil
                                                                                               message:@"This schedule already exist"
                                                                                         forController:self];
                                                       });
                                                     }
  }];
  if(!code){
    addFriendScheduleAction.enabled = false;
  }
  [addScheduleAlert addAction:cancelAction];
  [addScheduleAlert addAction:addFriendScheduleAction];
  [self presentViewController:addScheduleAlert animated:true completion:nil];
}

-(void)shareMySchedule{
  DCMainProxy* proxy = [DCMainProxy sharedProxy];
  if(![proxy favoriteEvents]){
    [DCAlertsManager showAlertControllerWithTitle:@"Currently you have no favourites" message:nil forController:self];
    return;
  }
  if(![proxy checkReachable]){
    [DCAlertsManager showAlertControllerWithTitle:@"Internet connection is not available at this moment. Please, try later." message:nil forController:self];
    return;
  }
  
  NSNumber* myCode = [NSUserDefaults myScheduleCode];
  NSArray *items = @[[NSString stringWithFormat:@"Hi, I have just published/shared my schedule for %@ where I will be an attendee.", EVENT_NAME],
                     [NSString stringWithFormat: @"Here is the link to add my schedule into the app: %@%@%@", SERVER_URL, @"schedule/share?code=", myCode],
                     @"If you have any issues with the link, use the Schedule Unique Code in the app to add my schedule manually.",
                     [NSString stringWithFormat:@"Schedule Unique Code: %@", myCode]]; // build an activity view controller
  UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
  controller.excludedActivityTypes = @[
                                               UIActivityTypePostToWeibo,
                                               UIActivityTypeMessage,
                                               UIActivityTypePrint,
                                               UIActivityTypeCopyToPasteboard,
                                               UIActivityTypeAssignToContact,
                                               UIActivityTypeSaveToCameraRoll,
                                               UIActivityTypeAddToReadingList,
                                               UIActivityTypePostToFlickr,
                                               UIActivityTypePostToVimeo,
                                               UIActivityTypePostToTencentWeibo
                                               ];
  [controller setValue:@"My Schedule" forKey:@"subject"];
  
  [self presentViewController:controller animated:true completion:nil];

}

-(void)showAddScheduleNameAlert:(NSDictionary *)scheduleDictionary{
  UIAlertController *addScheduleAlert = [UIAlertController alertControllerWithTitle:@"Schedule name"
                                                                            message:@"Enter a name for this schedule."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
  [addScheduleAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    textField.placeholder = @"Schedule name";
    textField.text = [NSString stringWithFormat:@"Schedule %@",scheduleDictionary[kDCCodeKey]];
    textField.delegate = self;
  }];
  okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    UITextField *textField = [[addScheduleAlert textFields] firstObject];
    NSManagedObjectContext *context = [DCMainProxy sharedProxy].workContext;
    [DCSharedSchedule updateFromDictionary:scheduleDictionary inContext:context];
    DCSharedSchedule* schedule = [DCSharedSchedule getScheduleFromDictionary:scheduleDictionary inContext:context];
    schedule.name = textField.text;
    dispatch_async(dispatch_get_main_queue(), ^{
      [[DCCoreDataStore defaultStore] saveWithCompletionBlock:^(BOOL isSuccess) {
        if (isSuccess) {
          [self setSchedulesTitle];
        }
      }];
    });
  }];
  [addScheduleAlert addAction:okAction];
  [self presentViewController:addScheduleAlert animated:true completion:nil];
}

-(void)showEditAlertView{
  UIAlertController *addScheduleAlert = [UIAlertController alertControllerWithTitle:@"Schedule name"
                                                                            message:nil
                                                                     preferredStyle:UIAlertControllerStyleAlert];
  [addScheduleAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    textField.placeholder = @"Schedule name";
    textField.text = selectedSchedule.name;
    textField.delegate = self;
  }];
  okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      selectedSchedule.name = addScheduleAlert.textFields.firstObject.text;
      [[DCCoreDataStore defaultStore] saveWithCompletionBlock:nil];
      titleString = selectedSchedule.name;
      [self setSchedulesTitle];
  }];
  [addScheduleAlert addAction:okAction];
  [self presentViewController:addScheduleAlert animated:true completion:nil];
}

-(void)showConfirmationAlertView{
  UIAlertController *confirmationAlertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"\"%@\" will be removed from your app", selectedSchedule.name]
                                                                            message:nil
                                                                     preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self removeSchedule];
  }];
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
  [confirmationAlertController addAction:cancelAction];
  [confirmationAlertController addAction:okAction];
  [self presentViewController:confirmationAlertController animated:true completion:nil];

}

-(void)removeSchedule{
  [[DCMainProxy sharedProxy] removeSchedule:selectedSchedule];
  [self setScheduleType:EMySchedule andSchedule:nil];
  [self setScheduleName:@"My Schedule"];
}

#pragma mark - User actions
-(void)onTitle{
  [self performSegueWithIdentifier:@"toSchedules" sender:self];
}

-(void)onMoreActionsButtonClick{
  if (selectedScheduleType == EMySchedule) {
    [self showMyScheduleActions];
  }else {
    [self showFriendScheduleActions];
  }
}

- (void)onFilterButtonClick {
  UINavigationController* filterController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"EventFilterviewController"];
  [(DCFilterViewController*)filterController.viewControllers[0]
      setDelegate:self];
  [self presentViewController:filterController animated:YES completion:nil];
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

-(void)dismissProgressHUD{
  dispatch_async(dispatch_get_main_queue(), ^{
    [SVProgressHUD dismiss];
  });
}

#pragma mark - DCFilterViewControllerDelegate

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

#pragma mark - ScheduleListDelegate

-(void)setScheduleName:(NSString *)name {
  titleString = name;
  [self setSchedulesTitle];
}

-(void)setScheduleType:(EScheduleType)scheduleType andSchedule:(DCSharedSchedule *)schedule {
  selectedScheduleType = scheduleType;
  selectedSchedule = schedule;
  if(scheduleType == EFriendSchedule){
    self.eventsStrategy = [[DCEventStrategy alloc] initWithStrategy:EDCEventStrategySharedSchedule andSchedule:schedule];
  }else{
    self.eventsStrategy = [[DCEventStrategy alloc] initWithStrategy:EDCEeventStrategyFavorites andSchedule:schedule];
  }
  [self createViewControllersForDays:self.eventsStrategy.days];
  [self reloadData];
}

#pragma mark - TextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSUInteger newLength = [textField.text length] + [string length] - range.length;
  NSString* stringWithoutSpaces = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
  if(!stringWithoutSpaces.length){
    addFriendScheduleAction.enabled = false;
    okAction.enabled = false;
    return true;
  }
  if(newLength > 0){
    addFriendScheduleAction.enabled = true;
    okAction.enabled = true;
  }else {
    addFriendScheduleAction.enabled = false;
    okAction.enabled = false;
  }
  return true;
}


#pragma mark - UIStoryboardSegue

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"EmbeddedDaysPageVC"]) {
        self.pageViewController = [segue destinationViewController];
        self.pageViewController.dataSource = self;
        self.pageViewController.delegate = self;
    }else if([[segue identifier] isEqualToString:@"toSchedules"]){
        DCSchedulesListTableViewController *controller = (DCSchedulesListTableViewController*)((UINavigationController *)segue.destinationViewController).topViewController;
        controller.delegate = self;
        controller.selectedSchedule = selectedSchedule;
    }
}

@end
