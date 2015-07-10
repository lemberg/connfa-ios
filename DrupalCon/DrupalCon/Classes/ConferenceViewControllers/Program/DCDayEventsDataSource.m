//
//  DCDayEventsDataSource.m
//  DrupalCon
//
//  Created by Olexandr on 3/12/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCDayEventsDataSource.h"


@interface DCDayEventsDataSource()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultController;

@end

@implementation DCDayEventsDataSource

- (void)loadEvents
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        [weakSelf reload];
        
    });
}

- (void) moveTableToCurrentTime
{
    self.tableView.alpha = 0;
    [self updateActualEventIndexPathForTimeRange:[self timeRangeSlotsDictionary]];
    
    [self.tableView scrollToRowAtIndexPath:self.actualEventIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [UIView transitionWithView:self.tableView
                      duration:0.25
                       options:UIViewAnimationOptionCurveLinear
                    animations:^{
                        self.tableView.alpha = 1;
                    }
                    completion:nil];
}

- (void)reloadEvents
{
    [self loadEvents];
}

- (NSArray *)timeRangeSlotsDictionary {
    NSMutableArray *timeRanges = [NSMutableArray array];
    for (id <NSFetchedResultsSectionInfo> sectionInfo in [self.fetchedResultController sections]) {
        [timeRanges addObject:@{kDCTimeslotKEY: sectionInfo.objects.firstObject}];
    }
    return timeRanges;
}

- (NSArray *)eventsForDay
{
    return [self.eventStrategy eventsForDay:self.selectedDay];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.fetchedResultController sections] count];//self.eventsByTimeRange.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}


- (DCEvent *)eventForIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultController objectAtIndexPath:indexPath];
}

- (DCTimeRange *)timeRangeForSection:(NSInteger)section
{
    
    return [self.fetchedResultController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
}

- (NSString *)titleForSectionAtIdexPath:(NSInteger)section
{
    //    TODO: Reload in the child classes
    return nil;
}


- (void)reload
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self.eventStrategy.eventClass)];
    NSSortDescriptor *sectionKeyDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeRange.from" ascending:YES] ;
    request.sortDescriptors = @[sectionKeyDescriptor];
    
    NSPredicate *predicate = [self.eventStrategy predicate];
    NSPredicate *dayPredicate = [NSPredicate predicateWithFormat:@"date == %@", self.selectedDay];
    if (predicate) {
        request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, dayPredicate]];
    } else {
        request.predicate = dayPredicate;
        
    }
    
    self.fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                   managedObjectContext:[DCMainProxy sharedProxy].workContext
                                                                     sectionNameKeyPath:@"timeRange.from"
                                                                              cacheName:nil];
    
    NSError *error = nil;
    [self.fetchedResultController performFetch:&error];
    
    if (error)
        NSLog(@"%@", error);
    [self.tableView reloadData];
    [self moveTableToCurrentTime];
}


@end
