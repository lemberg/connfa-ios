//
//  DCMainProxy+Additions.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/21/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCMainProxy+Additions.h"
#import "DCEvent+DC.h"
#import "DCProgram+DC.h"
#import "DCTimeRange+DC.h"

#import "NSDate+DC.h"
#import "NSArray+DC.h"

@implementation DCMainProxy (Additions)

#pragma mark -

- (NSArray*)days
{
    @try {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([DCProgram class]) inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entityDescription];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        [fetchRequest setPropertiesToFetch:@[@"date"]];
        [fetchRequest setResultType:NSDictionaryResultType];
        [fetchRequest setReturnsDistinctResults:YES];
        [fetchRequest setPredicate:nil];
        NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        if(result && [result count])
        {
            return [[result objectsFromDictionaries] sortedDates];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", [self.managedObjectContext description]);
        NSLog(@"%@", [self.managedObjectContext.persistentStoreCoordinator description]);
        NSLog(@"%@", [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel description]);
        NSLog(@"%@", [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel.entities description]);
        @throw exception;
    }
    @finally {
        
    }
    return nil;
}

- (NSArray*)programEventsForDayNum:(int)dayNum
{
    @try {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([DCProgram class]) inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date = %@", [[self days] objectAtIndex:dayNum]];
        [fetchRequest setPredicate:predicate];
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@""
    //                                                                   ascending:YES];
    //    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (error || !fetchedObjects)
        {
            NSLog(@"WRONG! program events fetch: %@", error);
        }
        return fetchedObjects;
    }
    @catch (NSException *exception) {
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", [self.managedObjectContext description]);
        NSLog(@"%@", [self.managedObjectContext.persistentStoreCoordinator description]);
        NSLog(@"%@", [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel description]);
        NSLog(@"%@", [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel.entities description]);
        @throw exception;
    }
    @finally {
        
    }
    return nil;
}

- (NSArray*)uniqueTimeRangesForDayNum:(NSInteger)dayNum
{
    @try {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([DCProgram class]) inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entityDescription];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"date = %@", [[self days] objectAtIndex:dayNum]];
        [fetchRequest setPredicate:predicate];
        NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        if(result && [result count])
        {
            return [[self DC_filterUniqueTimeRangeFromEvents:result] sortedByStartHour];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", [self.managedObjectContext description]);
        NSLog(@"%@", [self.managedObjectContext.persistentStoreCoordinator description]);
        NSLog(@"%@", [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel description]);
        NSLog(@"%@", [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel.entities description]);
        @throw exception;
    }
    @finally {
        
    }
    return nil;
}


#pragma mark -

- (NSArray*)DC_filterUniqueTimeRangeFromEvents:(NSArray*)events
{
    NSMutableArray * ranges = [[NSMutableArray alloc] initWithCapacity:events.count];
    for (DCProgram * event in events)
    {
        BOOL isUnique = YES;
        for (DCTimeRange* range in ranges)
        {
            if ([event.timeRange isEqualTo:range])
            {
                isUnique = NO;
                break;
            }
        }
        if (isUnique)
        {
            [ranges addObject:event.timeRange];
        }
    }
    return  ranges;
}

- (NSString*)DC_firstPartForDateString:(NSString*)string
{
    NSArray * components = [string componentsSeparatedByString:@" "];
    if (components.count == 0)
    {
        NSLog(@"WRONG! date string");
    }
    return components[0];
}

@end
