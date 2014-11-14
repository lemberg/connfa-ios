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
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *days;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton * nextBtn;
@property (weak, nonatomic) IBOutlet UIButton * prevBtn;

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
    [[DCMainProxy sharedProxy] setDataReadyCallback:^(DCMainProxyState mainProxyState) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_eventsStrategy days]) {
                 _days = [[NSArray alloc] initWithArray:[_eventsStrategy days]];
            } else {
                _days = nil;
            }
            self.viewControllers = [self DC_fillViewControllers];
            [self addPageController];
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

-(void) addPageController {
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    [self.pageViewController setViewControllers:@[self.viewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.delegate = self;
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0,  35, self.view.frame.size.width, self.view.frame.size.height - (35));
    [self addChildViewController: _pageViewController];
    
    [self.view addSubview: _pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self displayDateForDay: 0];
    [self DC_updateButtonsVisibility];
}

-(void) displayDateForDay: (NSInteger) day {
    NSDate * date = _days[day];
    self.dateLabel.text = [date pageViewDateString];
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
    [self DC_updateButtonsVisibility];
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
    [self DC_updateButtonsVisibility];

    [self displayDateForDay: self.currentIndex];
    [self.pageViewController setViewControllers: arrayOfViewController direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
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

- (void)DC_updateButtonsVisibility
{
    _prevBtn.hidden = (self.currentIndex == 0 ? YES : NO);
    _nextBtn.hidden = (self.currentIndex == (_days.count-1) ? YES : NO);
}

#pragma mark page view delegate and datasource


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
        self.currentIndex = currentIndex;
        [self displayDateForDay: self.currentIndex];
        [self DC_updateButtonsVisibility];
    }
}

@end
