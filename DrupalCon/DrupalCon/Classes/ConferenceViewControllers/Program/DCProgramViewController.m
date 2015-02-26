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
    
    self.currentDayIndex = 0;
    self.eventsStrategy.predicate = nil;
    
    [self.activityIndicator startAnimating];
    
    [[DCMainProxy sharedProxy] dataReadyBlock:^(BOOL isDataReady, BOOL isUpdatedFromServer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
            [self.activityIndicator stopAnimating];
        });
    }];
    
    if (![[DCMainProxy sharedProxy] isDataReady]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[DCMainProxy sharedProxy] update];
        });
    }
}

#pragma mark - Private

- (void) reloadData
{
    self.days = [[NSArray alloc] initWithArray:[self.eventsStrategy days]];
    self.viewControllers = [self createViewControllersForDays: self.days];
    if (self.days.count)
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
    
    for (int i = 0; i < aDays.count; i++)
    {
        DCProgramItemsViewController *dayViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProgramItemsViewController"];
        dayViewController.pageIndex = i;
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
    [self presentViewController:filterController animated:YES completion:nil];
}

- (void) filterControllerWillDismissWithResult:(NSArray *)selectedLevelsIds tracks:(NSArray *)selectetTracksIds
{
    if (!selectedLevelsIds && !selectetTracksIds)
        return;
    else
    {
            // TODO: add predicate making
        self.eventsStrategy.predicate = nil;//[NSPredicate predicateWithFormat:@"level.levelId IN %@", selectedLevelsIds];
        [self reloadData];
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
     NSUInteger index = ((DCProgramItemsViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return self.viewControllers[index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((DCProgramItemsViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == _days.count) {
        return nil;
    }
    return self.viewControllers[index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return _days.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;

}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if(completed){
        NSUInteger currentIndex = [[self.pageViewController.viewControllers lastObject] pageIndex];
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
