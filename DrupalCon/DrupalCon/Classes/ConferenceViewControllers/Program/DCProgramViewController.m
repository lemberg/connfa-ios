//
//  DCprogramViewController.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCProgramViewController.h"
#import "DCProgramItemsViewController.h"
#import "DCMainProxy+Additions.h"
#import "NSDate+DC.h"

@interface DCProgramViewController ()
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *days;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@end

@implementation DCProgramViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.activityIndicator startAnimating];
    [[DCMainProxy sharedProxy] dataReadyBlock:^(BOOL isDataReady, BOOL isUpdatedFromServer) {
        if (isDataReady && !isUpdatedFromServer && !self.viewControllers) {
            _days = [[NSArray alloc] initWithArray:[_eventsStrategy days]];
            
        } else if (isDataReady && isUpdatedFromServer) {
            [[[self pageViewController]view] removeFromSuperview];
            _days = [[NSArray alloc] initWithArray:[_eventsStrategy days]];
        }
        self.viewControllers = [self DC_fillViewControllers];
        [self addPageController];
        [self.activityIndicator stopAnimating];
    }];

}

-(void) addPageController {
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
//    DCProgramItemsViewController *eventItemsViewController = self.viewControllers[0];
//    eventItemsViewController.eventsStrategy = self.eventsStrategy;
    
//    self.viewControllers = [[NSArray alloc] initWithObjects: eventItemsViewController, nil];
    [self.pageViewController setViewControllers:@[self.viewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.delegate = self;
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0,  35, self.view.frame.size.width, self.view.frame.size.height - (35));
    [self addChildViewController: _pageViewController];
    
    [self.view addSubview: _pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self displayDateForDay: 0];
}

-(void) displayDateForDay: (NSInteger) day {
    NSDate * date = _days[day];
    self.dateLabel.text = [date pageViewDateString];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if(completed){
       NSUInteger currentIndex = [[self.pageViewController.viewControllers lastObject] pageIndex];
        self.currentIndex = currentIndex;
        [self displayDateForDay: self.currentIndex];
    }
}


-(IBAction) previousDayClicked:(id)sender
{
    if(self.currentIndex == 0)
        return;
    
    NSMutableArray *arrayOfViewController = [[NSMutableArray alloc] init];
    
    for(int i = (int)_days.count-1; i >= 0; i--) {
        if(i < self.currentIndex) {
            [arrayOfViewController addObject: self.viewControllers[i]];
            break;
        }
    }
    self.currentIndex -= 1;
    [self displayDateForDay: self.currentIndex];

    [self.pageViewController setViewControllers: arrayOfViewController direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:NULL];
}


-(IBAction) nextDayClicked:(id)sender
{
    if(self.currentIndex >= _days.count-1)
        return;
    
    NSMutableArray *arrayOfViewController = [[NSMutableArray alloc] init];
    for(int i = 0; i < _days.count; i++) {
        if(i > self.currentIndex) {
            [arrayOfViewController addObject: self.viewControllers[i]];
            break;
        }

    }
    self.currentIndex += 1;
    [self displayDateForDay: self.currentIndex];
    [self.pageViewController setViewControllers: arrayOfViewController direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
}

#pragma mark page view delegate and datasource
- (DCProgramItemsViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if ((_days.count == 0) || (index >= _days.count)) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    DCProgramItemsViewController *eventItemsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProgramItemsViewController"];
    eventItemsViewController.pageIndex = index;
    eventItemsViewController.eventsStrategy = self.eventsStrategy;
    return eventItemsViewController;
}

- (NSArray*)DC_fillViewControllers
{
    NSMutableArray * controllers_ = [[NSMutableArray alloc] initWithCapacity:_days.count];
    for (int i = 0; i<_days.count; i++)
    {
        DCProgramItemsViewController *eventItemsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProgramItemsViewController"];
        eventItemsViewController.pageIndex = i;
        eventItemsViewController.eventsStrategy = self.eventsStrategy;
        [controllers_ addObject:eventItemsViewController];
    }
    return controllers_;
}

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
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return _days.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
