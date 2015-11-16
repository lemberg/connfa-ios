/**********************************************************************************
 *                                                                           
 *  The MIT License (MIT)
 *  Copyright (c) 2015 Lemberg Solutions Limited
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the 
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *   The above copyright notice and this permission notice shall be included in
 *   all  copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM,  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 *  IN THE SOFTWARE.
 *
 *                                                                           
 *****************************************************************************/



#import "DCDayEventsDataSource.h"

@interface DCDayEventsDataSource ()
@property(strong, nonatomic)
    NSFetchedResultsController* fetchedResultController;

@end

@implementation DCDayEventsDataSource

- (void)loadEvents {
  __weak typeof(self) weakSelf = self;
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        NSArray* uniqueTimeSlotForDay =
            [self.eventStrategy uniqueTimeRangesForDay:self.selectedDay];
        NSArray* eventsByTimeRange =
            [self eventsSortedByTimeRange:[self eventsForDay]
                      withUniqueTimeRange:uniqueTimeSlotForDay];
        [self updateActualEventIndexPathForTimeRange:eventsByTimeRange];
        dispatch_async(dispatch_get_main_queue(), ^{
          //
          __strong __typeof__(weakSelf) strongSelf = weakSelf;
          strongSelf.eventsByTimeRange = eventsByTimeRange;
          [strongSelf.tableView reloadData];

          // when this controller shows Current day
          if (strongSelf.actualEventIndexPath)
            [strongSelf moveTableToCurrentTime];

        });
      });
}

- (void)moveTableToCurrentTime {
  self.tableView.alpha = 0;
  [self.tableView scrollToRowAtIndexPath:self.actualEventIndexPath
                        atScrollPosition:UITableViewScrollPositionTop
                                animated:NO];

  [UIView transitionWithView:self.tableView
                    duration:0.25
                     options:UIViewAnimationOptionCurveLinear
                  animations:^{
                    self.tableView.alpha = 1;
                  }
                  completion:nil];
}

- (void)reloadEvents {
  [self loadEvents];
}

- (NSArray*)eventsForDay {
  return [self.eventStrategy eventsForDay:self.selectedDay];
}

@end
