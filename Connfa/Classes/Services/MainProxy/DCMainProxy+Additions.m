
#import "DCMainProxy+Additions.h"
#import "DCEvent+DC.h"
#import "DCMainEvent+DC.h"
#import "DCBof.h"
#import "DCTimeRange+DC.h"
#import "DCLevel+CoreDataProperties.h"
#import "DCTrack+CoreDataProperties.h"
#import "DCSharedSchedule+CoreDataClass.h"
#import "DCSharedSchedule+DC.h"
#import "NSManagedObject+DC.h"

#import "NSDate+DC.h"
#import "NSArray+DC.h"
#import "DCWebService.h"

@implementation DCMainProxy (Additions)

#pragma mark -

- (NSArray*)daysForClass:(Class)eventClass {
  return [self daysForClass:eventClass predicate:nil];
}

- (NSArray*)daysForClass:(Class)eventClass predicate:(NSPredicate*)aPredicate {
  @try {
    NSEntityDescription* entityDescription =
        [NSEntityDescription entityForName:NSStringFromClass(eventClass)
                    inManagedObjectContext:self.workContext];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setPropertiesToFetch:@[ @"date" ]];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setReturnsDistinctResults:YES];

    [fetchRequest setPredicate:aPredicate];
    NSArray* result =
        [self.workContext executeFetchRequest:fetchRequest error:nil];
    if (result && [result count]) {
      return [[result objectsFromDictionaries] sortedDates];
    }
  } @catch (NSException* exception) {
    NSLog(@"%@", NSStringFromClass([self class]));
    NSLog(@"%@", [self.workContext description]);
    NSLog(@"%@", [self.workContext.persistentStoreCoordinator description]);
    NSLog(@"%@", [self.workContext.persistentStoreCoordinator
                         .managedObjectModel description]);
    NSLog(@"%@", [self.workContext.persistentStoreCoordinator.managedObjectModel
                         .entities description]);
    @throw exception;
  } @finally {
  }
  return nil;
}

- (NSArray*)eventsForDay:(NSDate*)day
                forClass:(__unsafe_unretained Class)eventClass {
  return [self eventsForDay:day forClass:eventClass predicate:nil];
}

- (NSArray*)eventsForDay:(NSDate*)day
                forClass:(__unsafe_unretained Class)eventClass
               predicate:(NSPredicate*)aPredicate {
  @try {
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity =
        [NSEntityDescription entityForName:NSStringFromClass(eventClass)
                    inManagedObjectContext:self.workContext];
    [fetchRequest setEntity:entity];

    NSPredicate* datePredicate =
        [NSPredicate predicateWithFormat:@"date = %@", day];
    NSPredicate* mergedPredicate =
        aPredicate
            ? [NSCompoundPredicate
                  andPredicateWithSubpredicates:@[ datePredicate, aPredicate ]]
            : datePredicate;

    [fetchRequest setPredicate:mergedPredicate];

    NSError* error = nil;
    NSArray* fetchedObjects =
        [self.workContext executeFetchRequest:fetchRequest error:&error];
    if (error || !fetchedObjects) {
      NSLog(@"WRONG! program events fetch: %@", error);
    }
    return fetchedObjects;
  } @catch (NSException* exception) {
    NSLog(@"%@", NSStringFromClass([self class]));
    NSLog(@"%@", [self.workContext description]);
    NSLog(@"%@", [self.workContext.persistentStoreCoordinator description]);
    NSLog(@"%@", [self.workContext.persistentStoreCoordinator
                         .managedObjectModel description]);
    NSLog(@"%@", [self.workContext.persistentStoreCoordinator.managedObjectModel
                         .entities description]);
    @throw exception;
  } @finally {
  }
  return nil;
}

- (NSArray*)uniqueTimeRangesForDay:(NSDate*)day
                          forClass:(__unsafe_unretained Class)eventClass {
  return [self uniqueTimeRangesForDay:day forClass:eventClass predicate:nil];
}

- (NSArray*)uniqueTimeRangesForDay:(NSDate*)day
                          forClass:(__unsafe_unretained Class)eventClass
                         predicate:(NSPredicate*)aPredicate {
  @try {
    NSEntityDescription* entityDescription =
        [NSEntityDescription entityForName:NSStringFromClass(eventClass)
                    inManagedObjectContext:self.workContext];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setReturnsObjectsAsFaults:NO];

    NSPredicate* datePredicate =
        [NSPredicate predicateWithFormat:@"date = %@", day];
    NSPredicate* mergedPredicate =
        aPredicate
            ? [NSCompoundPredicate
                  andPredicateWithSubpredicates:@[ datePredicate, aPredicate ]]
            : datePredicate;
    [fetchRequest setPredicate:mergedPredicate];

    NSArray* result =
        [self.workContext executeFetchRequest:fetchRequest error:nil];
    if (result && [result count]) {
      return
          [[self DC_filterUniqueTimeRangeFromEvents:result] sortedByStartHour];
    }
  } @catch (NSException* exception) {
    NSLog(@"%@", NSStringFromClass([self class]));
    NSLog(@"%@", [self.workContext description]);
    NSLog(@"%@", [self.workContext.persistentStoreCoordinator description]);
    NSLog(@"%@", [self.workContext.persistentStoreCoordinator
                         .managedObjectModel description]);
    NSLog(@"%@", [self.workContext.persistentStoreCoordinator.managedObjectModel
                         .entities description]);
    @throw exception;
  } @finally {
  }
  return nil;
}

- (NSArray*)favoriteEvents {
  return [self favoriteEventsWithPredicate:nil];
}

- (NSArray*)favoriteEventsWithPredicate:(NSPredicate*)aPredicate {
  @try {
    NSEntityDescription* entityDescription =
        [NSEntityDescription entityForName:NSStringFromClass([DCEvent class])
                    inManagedObjectContext:self.workContext];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate* predicate = [NSPredicate
        predicateWithFormat:@"favorite=%@", [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];

    NSArray* result =
        [self.workContext executeFetchRequest:fetchRequest error:nil];
    NSArray* uniqueDates =
        [result valueForKeyPath:@"@distinctUnionOfObjects.date"];
    NSArray* sortDates = [uniqueDates sortedDates];
    NSMutableArray* eventsByDate = [NSMutableArray array];
    for (id date in sortDates) {
      NSPredicate* predicate =
          [NSPredicate predicateWithFormat:@"date == %@", date];
      NSArray* eventsForOneDay = [result filteredArrayUsingPredicate:predicate];
      NSArray* uniqueSection = [[self DC_filterUniqueTimeRangeFromEvents:
                                          eventsForOneDay] sortedByStartHour];
      NSDictionary* dayInfo = @{
        @"sections" : [NSMutableArray arrayWithArray:uniqueSection],
        @"events" : [NSMutableArray arrayWithArray:eventsForOneDay]
      };
      [eventsByDate addObject:dayInfo];
    }

    if (eventsByDate && [eventsByDate count]) {
      return eventsByDate;
    }
  } @catch (NSException* exception) {
    NSLog(@"%@", NSStringFromClass([self class]));
    NSLog(@"%@", [self.workContext description]);
    NSLog(@"%@", [self.workContext.persistentStoreCoordinator description]);
    NSLog(@"%@", [self.workContext.persistentStoreCoordinator
                         .managedObjectModel description]);
    NSLog(@"%@", [self.workContext.persistentStoreCoordinator.managedObjectModel
                         .entities description]);
    @throw exception;
  } @finally {
  }

  return nil;
}

- (BOOL)isFilterCleared {
  NSArray* levels =
      [self getAllInstancesOfClass:[DCLevel class] inMainQueue:YES];
  NSArray* tracks =
      [self getAllInstancesOfClass:[DCTrack class] inMainQueue:YES];

  for (DCLevel* level in levels)
    if (![level.selectedInFilter boolValue])
      return NO;

  for (DCTrack* track in tracks)
    if (![track.selectedInFilter boolValue])
      return NO;

  return YES;
}

-(void)createSchedule{
  NSMutableURLRequest* request = [DCWebService mutableURLRequestForURI:@"createSchedule" withHTTPMethod:@"POST" ];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:[self createDataForScheduleRequest]];
  [DCWebService fetchDataFromURLRequest:request onSuccess:^(NSHTTPURLResponse *response, id data) {
    NSLog(@"%@",response);
    DCSharedSchedule* sharedSchedule = [DCSharedSchedule createManagedObjectInContext:self.workContext];
    
  } onError:^(NSHTTPURLResponse *response, id data, NSError *error) {
    NSLog(@"%@",error.description);
  }];
}

-(NSData *)createDataForScheduleRequest{
  NSArray* events = [self favoriteEvents];
  if(!events.count){
    return nil;
  }
  NSMutableArray *ids = [[NSMutableArray alloc] init];
  for(DCEvent* event in events){
    [ids addObject:event.eventId];
  }
  NSDictionary* dataDictionary = [NSDictionary dictionaryWithObject:ids forKey:@"data"];
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:nil];
  return jsonData;
}


#pragma mark -

- (NSArray*)DC_filterUniqueTimeRangeFromEvents:(NSArray*)events {
  NSMutableArray* ranges =
      [[NSMutableArray alloc] initWithCapacity:events.count];
  for (DCMainEvent* event in events) {
    BOOL isUnique = YES;
    for (DCTimeRange* range in ranges) {
      if ([event.timeRange isEqualTo:range]) {
        isUnique = NO;
        break;
      }
    }

#warning need to call in main thread
    
    if (isUnique) {
      [ranges addObject:event.timeRange];
    }

  }
  return ranges;
}

- (NSString*)DC_firstPartForDateString:(NSString*)string {
  NSArray* components = [string componentsSeparatedByString:@" "];
  if (components.count == 0) {
    NSLog(@"WRONG! date string");
  }
  return components[0];
}

@end
