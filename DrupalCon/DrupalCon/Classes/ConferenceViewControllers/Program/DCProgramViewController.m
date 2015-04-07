//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DCProgramViewController.h"
#import "DCProgramItemsViewController.h"
#import "DCMainProxy+Additions.h"
#import "NSDate+DC.h"
#import "DCDayEventsController.h"

@interface DCProgramViewController ()

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *nextDayButton;
@property (weak, nonatomic) IBOutlet UIButton *previousDayButton;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *days;
@property (nonatomic) NSInteger currentDayIndex;
@property (nonatomic, strong) NSDate* currentPageDate; // used to set current Date after filtering

@end

@implementation DCProgramViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self arrangeNavigationBar];
    
    self.currentDayIndex = 0;
    self.currentPageDate = nil;
    
    [self.activityIndicator startAnimating];
    [[DCMainProxy sharedProxy] setDataReadyCallback:^(DCMainProxyState mainProxyState) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];

            [self.activityIndicator stopAnimating];
        });
    }];
}

#pragma mark - Private

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) arrangeNavigationBar
{
    [super arrangeNavigationBar];
    
    [self setFilterButton];
}

- (NSUInteger) getCurrentDayIndex: (NSDate*)neededDate
{
    NSDateComponents *neededDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: neededDate];
    NSInteger neededDay = [neededDateComponents day];
    NSInteger neededMonth = [neededDateComponents month];
    NSInteger neededYear = [neededDateComponents year];
    
    for (NSDate* iteratedDay in self.days)
    {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: iteratedDay];
        NSInteger day = [components day];
        NSInteger month = [components month];
        NSInteger year = [components year];
        
        if ((neededYear == year) && (neededMonth == month) && (neededDay == day))
            return [self.days indexOfObject:iteratedDay];
        else
        {
            if (iteratedDay.timeIntervalSince1970 > neededDate.timeIntervalSince1970)
               return [self.days indexOfObject:iteratedDay];
        }
    }
    
    return self.days.count ?  self.days.count-1 : 0;
}

- (void) reloadData
{
    self.days = self.eventsStrategy.days.count ? [[NSArray alloc] initWithArray:[_eventsStrategy days]] : nil;

        // set current page Index to set proper Date after filtering
    if (self.currentPageDate)
    {
        self.currentDayIndex = [self getCurrentDayIndex:self.currentPageDate];
        self.currentPageDate = nil;
    }
    
    self.viewControllers = [self createViewControllersForDays: self.days];
    [self updatePageController];
    [self updateButtonsVisibility];
}

-(void) updatePageController
{
    [self.pageViewController setViewControllers:@[self.viewControllers[self.currentDayIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self displayDateForDay: self.currentDayIndex];
}

-(void) displayDateForDay: (NSInteger) day
{
    NSDate * date = _days[day];
    self.dateLabel.text = date ? [date pageViewDateString] : nil;
}

- (NSArray*)createViewControllersForDays:(NSArray*)aDays
{
    if (aDays.count)
    {
        NSMutableArray * controllers = [[NSMutableArray alloc] initWithCapacity: aDays.count];
        NSUInteger currentDatePageIndex = 0;
        NSInteger daysCount = [aDays count];
        if ( daysCount && self.currentDayIndex >= daysCount) {
            self.currentDayIndex = 0;
        }
        for (NSDate* date in self.days)
        {
            if ([NSDate dc_isDateInToday:date])
                self.currentDayIndex = currentDatePageIndex;
            
            DCDayEventsController *dayEventsController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([DCDayEventsController class])];
            dayEventsController.date = date;
            dayEventsController.eventsStrategy = self.eventsStrategy;
            
            [controllers addObject:dayEventsController];
            currentDatePageIndex++;
        }
        return controllers;
    }
    else // make stub controller with no items
    {
        DCDayEventsController *dayEventsController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([DCDayEventsController class])];
        
        if (self.eventsStrategy.strategy == EDCEeventStrategyFavorites)
            [dayEventsController initAsStubControllerWithImage:[UIImage imageNamed:@"empty_icon"]];
        else
            [dayEventsController initAsStubControllerWithString:@"No Matching Events"];
             
        return @[dayEventsController];
    }
}

- (void)updateButtonsVisibility
{
    _previousDayButton.hidden = (self.currentDayIndex == 0 ? YES : NO);
    _nextDayButton.hidden = (self.currentDayIndex == (_days.count-1) || !self.days.count ? YES : NO);
}

- (void) setFilterButton
{
    if (![self.eventsStrategy isEnableFilter]) {
        return;
    }
    UIImage* filterImage = [UIImage imageNamed: [[DCMainProxy sharedProxy] isFilterCleared] ? @"filter-" : @"filter+"];
    UIBarButtonItem* filterButton = [[UIBarButtonItem alloc] initWithImage:filterImage
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(onFilterButtonClick)];
    
    
    self.navigationItem.rightBarButtonItem = filterButton;
}

#pragma mark - User actions

- (void) onFilterButtonClick
{
    UINavigationController *filterController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventFilterviewController"];
    [(DCFilterViewController*)filterController.viewControllers[0] setDelegate:self];
    [self presentViewController:filterController animated:YES completion:nil];
}

- (void) filterControllerWillDismiss:(BOOL)cancel
{
    if (!cancel)
    {
        self.pageViewController.dataSource = nil;
        self.currentPageDate = self.days[self.currentDayIndex];
        
        [self setFilterButton];
        [self reloadData];
       
        self.pageViewController.dataSource = self;
        [self setCurrentDayControllerAtIndex:self.currentDayIndex];
    }
}

- (void)updateControllersaToFilterValues
{
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController conformsToProtocol:@protocol(DCUpdateDayEventProtocol)]) {
            [(id<DCUpdateDayEventProtocol>)viewController updateEvents];
        }
        break;
    }
}

-(IBAction) previousDayClicked:(id)sender
{
    if(self.currentDayIndex == 0)
        return;

    self.currentDayIndex--;
    
    [self updateButtonsVisibility];
    [self displayDateForDay: self.currentDayIndex];
    [self.pageViewController setViewControllers: @[self.viewControllers[self.currentDayIndex]]
                                      direction: UIPageViewControllerNavigationDirectionReverse
                                       animated: YES
                                     completion: nil];
}

- (void)setCurrentDayControllerAtIndex:(NSUInteger)pageIndex
{

    [self updateButtonsVisibility];
    [self displayDateForDay: pageIndex];
    [self.pageViewController setViewControllers: @[self.viewControllers[pageIndex]]
                                      direction: UIPageViewControllerNavigationDirectionReverse
                                       animated: NO
                                     completion: nil];
}

-(IBAction) nextDayClicked:(id)sender
{
    if(self.currentDayIndex >= self.days.count-1)
        return;
    
    self.currentDayIndex++;
    
    [self updateButtonsVisibility];
    [self displayDateForDay: self.currentDayIndex];
    [self.pageViewController setViewControllers: @[self.viewControllers[self.currentDayIndex]]
                                      direction: UIPageViewControllerNavigationDirectionForward
                                       animated: YES
                                     completion: nil];
}

#pragma mark - UIPageViewController delegate and datasource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
     NSUInteger index = [self.days indexOfObject: ((DCProgramItemsViewController*) viewController).date];
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return self.viewControllers[index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (!self.days.count)
        return nil;
    
     NSUInteger index = [self.days indexOfObject: ((DCProgramItemsViewController*) viewController).date];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == _days.count) {
        return nil;
    }
    return self.viewControllers[index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if(completed){
        NSUInteger currentIndex = [self.days indexOfObject:[(DCProgramItemsViewController*)[self.pageViewController.viewControllers lastObject] date]];
        self.currentDayIndex = currentIndex;
        [self displayDateForDay: self.currentDayIndex];
        [self updateButtonsVisibility];
    }
}

#pragma mark - UIStoryboardSegue delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EmbeddedDaysPageVC"])
    {
        self.pageViewController = [segue destinationViewController];
        self.pageViewController.dataSource = self;
        self.pageViewController.delegate = self;
    }
}

@end
