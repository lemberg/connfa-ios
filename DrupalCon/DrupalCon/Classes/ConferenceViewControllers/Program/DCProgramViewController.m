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

@interface DCProgramViewController ()

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *nextDayButton;
@property (weak, nonatomic) IBOutlet UIButton *previousDayButton;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *days;
@property (nonatomic) NSInteger currentDayIndex;

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
    self.eventsStrategy.predicate = nil;
    
    [self.activityIndicator startAnimating];
    [[DCMainProxy sharedProxy] setDataReadyCallback:^(DCMainProxyState mainProxyState) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_eventsStrategy days]) {
                 _days = [[NSArray alloc] initWithArray:[_eventsStrategy days]];
            } else {
                _days = nil;
            }
//            self.viewControllers = [self DC_fillViewControllers];
//            [self addPageController];
            [self reloadData];
            [self.activityIndicator stopAnimating];
        });
    }];
    /*
    if (![[DCMainProxy sharedProxy] isDataReady]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[DCMainProxy sharedProxy] update];
        });
    }
     */
}

#pragma mark - Private

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) arrangeNavigationBar
{
    [super arrangeNavigationBar];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButtonClick)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void) reloadData
{
    self.days = [self.eventsStrategy days];
    
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
    self.dateLabel.text = [date pageViewDateString];
}

- (NSArray*)createViewControllersForDays:(NSArray*)aDays
{
    NSMutableArray * controllers = [[NSMutableArray alloc] initWithCapacity: aDays.count];
    
    for (NSDate* date in self.days)
    {
        DCProgramItemsViewController *dayViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProgramItemsViewController"];
        dayViewController.date = date;
        dayViewController.eventsStrategy = self.eventsStrategy;
        [controllers addObject:dayViewController];
    }
    
    return controllers;
}

- (void)updateButtonsVisibility
{
    _previousDayButton.hidden = (self.currentDayIndex == 0 ? YES : NO);
    _nextDayButton.hidden = (self.currentDayIndex == (_days.count-1) ? YES : NO);
}

#pragma mark - User actions

- (void) onFilterButtonClick
{
    UINavigationController *filterController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventFilterviewController"];
    [(DCFilterViewController*)filterController.viewControllers[0] setDelegate:self];
    [self presentViewController:filterController animated:YES completion:nil];
}

- (void) filterControllerWillDismissWithResult:(NSArray *)selectedLevelsIds tracks:(NSArray *)selectetTracksIds
{
    if (!selectedLevelsIds && !selectetTracksIds)
    {
        if (self.eventsStrategy.predicate != nil)
        {
                // User clicked Done with empty filter, show all events if needed
            self.eventsStrategy.predicate = nil;
            [self reloadData];
        }
    }
    else
    {
            // User has set Filter
        NSPredicate* levelPredicate = selectedLevelsIds ? [NSPredicate predicateWithFormat:@"level.levelId IN %@",selectedLevelsIds] : nil;
        NSPredicate* trackPredicate = selectetTracksIds ? [NSPredicate predicateWithFormat:@"ANY tracks.trackId IN %@",selectetTracksIds] : nil;

        NSPredicate* mergedPredicate;
        
        if (levelPredicate && trackPredicate)
            mergedPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[levelPredicate,trackPredicate]];
        else
            mergedPredicate = levelPredicate ? levelPredicate : trackPredicate;
        
        self.eventsStrategy.predicate = mergedPredicate;
        
        [self reloadData];
    }
}

- (NSArray*)DC_fillViewControllers
{
    
    NSMutableArray * controllers_ = [[NSMutableArray alloc] initWithCapacity:_days.count];
    for (int i = 0; i<_days.count; i++)
    {
        DCProgramItemsViewController *eventItemsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProgramItemsViewController"];
//        eventItemsViewController.pageIndex = i;
        eventItemsViewController.eventsStrategy = self.eventsStrategy;
        [controllers_ addObject:eventItemsViewController];
    }
    return controllers_;
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

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
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
