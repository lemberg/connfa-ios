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
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        weakSelf
//        NSArray *uniqueTimeSlotForDay = [self.eventStrategy uniqueTimeRangesForDay:self.selectedDay];
//        NSArray *eventsByTimeRange = [self eventsSortedByTimeRange:[self eventsForDay]
//                                               withUniqueTimeRange:uniqueTimeSlotForDay];
//        [self updateActualEventIndexPathForTimeRange:eventsByTimeRange];
//        dispatch_async(dispatch_get_main_queue(), ^{
////            
//            __strong __typeof__(weakSelf) strongSelf = weakSelf;
//            strongSelf.eventsByTimeRange = eventsByTimeRange;
//            [strongSelf.tableView reloadData];
//            
//                // when this controller shows Current day
//            if (strongSelf.actualEventIndexPath)
//                [strongSelf moveTableToCurrentTime];
//
//        });
//    });
}

- (void) moveTableToCurrentTime
{
    self.tableView.alpha = 0;
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


- (NSArray *)eventsForDay
{
    return [self.eventStrategy eventsForDay:self.selectedDay];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.fetchedResultController sections] count];//self.eventsByTimeRange.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];//[self.eventsByTimeRange[section][kDCTimeslotEventKEY] count];
}


- (DCEvent *)eventForIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultController objectAtIndexPath:indexPath];//self.eventsByTimeRange[indexPath.section][kDCTimeslotEventKEY][indexPath.row];
}

- (DCTimeRange *)timeRangeForSection:(NSInteger)section
{
    //    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultController sections] objectAtIndex:section];
    
    return [self.fetchedResultController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]]; //self.eventsByTimeRange[section][kDCTimeslotKEY];
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
    //    NSSortDescriptor *firstNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES] ;
    //    NSSortDescriptor *lastNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    
    //    request.sortDescriptors = @[sectionKeyDescriptor, firstNameDescriptor, lastNameDescriptor];
    
    NSPredicate *predicate = [self.eventStrategy predicate];
    NSPredicate *dayPredicate = [NSPredicate predicateWithFormat:@"date == %@", self.selectedDay];
    if (predicate) {
        request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, dayPredicate]];
    } else {
        request.predicate = dayPredicate;
        
    }
    
    _fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                   managedObjectContext:[DCMainProxy sharedProxy].workContext
                                                                     sectionNameKeyPath:@"timeRange.from"
                                                                              cacheName:nil];
    //    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    [self.fetchedResultController performFetch:&error];
    
    if (error)
        NSLog(@"%@", error);
    [self.tableView reloadData];
    BOOL itemsEnabled = self.fetchedResultController.fetchedObjects.count;
}


@end
