
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
#import "NSUserDefaults+DC.h"
#import "DCWebService.h"
#import "DCCoreDataStore.h"

#import "NSDate+DC.h"
#import "NSArray+DC.h"

@implementation DCMainProxy (Additions)

#pragma mark -

- (NSArray*)daysForClass:(Class)eventClass {
  return [self daysForClass:eventClass eventStrategy: nil predicate:nil];
}

- (NSArray*)daysForClass:(Class)eventClass eventStrategy:(DCEventStrategy *)eventStrategy predicate:(NSPredicate*)aPredicate {
  if(eventStrategy.strategy == EDCEventStrategySharedSchedule){
    NSMutableArray* dates = [[NSMutableArray alloc] init];
    for (DCEvent* event in eventStrategy.schedule.events) {
      [dates addObject:[event.date dateWithoutTime]];
    }
    return [dates uniqueDates];
  }
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
  return [self eventsForDay:day forClass:eventClass eventStrategy: nil predicate:nil];
}

- (NSArray*)eventsForDay:(NSDate*)day
                forClass:(__unsafe_unretained Class)eventClass
           eventStrategy:(DCEventStrategy *)eventStrategy
               predicate:(NSPredicate*)aPredicate {
  if (eventStrategy.strategy == EDCEventStrategySharedSchedule) {
    NSSet* events = eventStrategy.schedule.events;
    NSMutableArray *eventsForDay = [[NSMutableArray alloc] init];
    for (DCEvent* event in events) {
      NSDate *eventDate = event.date;
      NSDateComponents *eventDatecomponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:eventDate];
      NSDateComponents *dayDatecomponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:day];
      if ((eventDatecomponents.year == dayDatecomponents.year) && (eventDatecomponents.month == dayDatecomponents.month) && (eventDatecomponents.day == dayDatecomponents.day)) {
        [eventsForDay addObject:event];
      }
    }
    return eventsForDay;
  }
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
  return [self uniqueTimeRangesForDay:day forClass:eventClass eventStrategy:nil predicate:nil];
}

- (NSArray*)uniqueTimeRangesForDay:(NSDate*)day
                          forClass:(__unsafe_unretained Class)eventClass
                     eventStrategy:(DCEventStrategy *)eventStrategy
                         predicate:(NSPredicate*)aPredicate {
  if(eventStrategy.strategy == EDCEventStrategySharedSchedule){
    NSArray* result = [self eventsForDay:day forClass:[DCEvent class] eventStrategy:eventStrategy predicate:nil];
    return [[self DC_filterUniqueTimeRangeFromEvents:result] sortedByStartHour];
  }
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

-(NSArray*)getAllFavoritesEvents {
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
  return result;
}

- (NSArray*)favoriteEventsWithPredicate:(NSPredicate*)aPredicate {
  @try {
    
    NSArray* result = [self getAllFavoritesEvents];
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

//TODO: Add error handling, refactor for 1 schedule
-(void)getSchedules:(NSArray*)codes callback:(void (^)(BOOL, DCSharedSchedule*))callback{
    NSString* url = [NSString stringWithFormat:@"getSchedules?%@",[self createParametersStringForCodes:codes]];
    NSURLRequest* request = [DCWebService urlRequestForURI:url withHTTPMethod:@"GET" withHeaderOptions:nil];
    [DCWebService fetchDataFromURLRequest:request onSuccess:^(NSHTTPURLResponse *response, id data) {
        NSError* err = nil;
        NSDictionary* dictionary =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:kNilOptions
                                          error:&err];
        dictionary = [dictionary dictionaryByReplacingNullsWithStrings];

        [DCSharedSchedule updateFromDictionary:dictionary inContext:self.workContext];
        NSDictionary *scheduleDictionary = [((NSArray *)[dictionary objectForKey:@"schedules"]) firstObject];
        DCSharedSchedule *schedule = [DCSharedSchedule getScheduleFromDictionary:scheduleDictionary inContext:self.workContext];
        callback(true, schedule);
    } onError:^(NSHTTPURLResponse *response, id data, NSError *error) {
        
    }];
}
-(BOOL)isScheduleAdded:(NSString *)idString {
  return [[DCMainProxy sharedProxy] getScheduleWithId:idString].count;
}
//TODO: Replace
-(NSString*)createParametersStringForCodes:(NSArray *)codes{
    NSMutableString* parametesString = [[NSMutableString alloc] init];
    for (NSNumber* code in codes) {
        [parametesString appendString:[NSString stringWithFormat:@"codes[]=%@", code]];
        if(code != [codes lastObject]){
            [parametesString appendString:@"&"];
        }
    }
    return parametesString;
}

-(void)updateSchedule{
    NSNumber *code = [NSUserDefaults myScheduleCode];
    if (!code) {
        [self createSchedule];
    }else{
        NSMutableURLRequest* request = [DCWebService mutableURLRequestForURI:[NSString stringWithFormat:@"updateSchedule/%@",[code stringValue]] withHTTPMethod:@"PUT" ];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[self createDataForScheduleRequest]];
        [DCWebService fetchDataFromURLRequest:request onSuccess:^(NSHTTPURLResponse *response, id data) {
            NSLog(@"%@",response);
        } onError:^(NSHTTPURLResponse *response, id data, NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }
}

-(void)createSchedule{
    if(![NSUserDefaults myScheduleCode]){
        NSMutableURLRequest* request = [DCWebService mutableURLRequestForURI:@"createSchedule" withHTTPMethod:@"POST" ];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[self createDataForScheduleRequest]];
        [DCWebService fetchDataFromURLRequest:request onSuccess:^(NSHTTPURLResponse *response, id data) {
            NSLog(@"%@",response);
            NSError* err = nil;
            NSDictionary* dictionary =
            [NSJSONSerialization JSONObjectWithData:data
                                            options:kNilOptions
                                              error:&err];
            dictionary = [dictionary dictionaryByReplacingNullsWithStrings];
            NSNumber *code = [dictionary objectForKey:@"code"];
            
            DCSharedSchedule* sharedSchedule = [DCSharedSchedule createManagedObjectInContext:self.workContext];
            sharedSchedule.scheduleId = code;
            sharedSchedule.isMySchedule = [NSNumber numberWithBool:true];
            sharedSchedule.name = @"My Schedule";
            [sharedSchedule addEventsForIds:[self getFavoritesIds]];
            [[DCCoreDataStore defaultStore] saveWithCompletionBlock:nil];
            
            [NSUserDefaults saveMyScheduleCode:code];
        } onError:^(NSHTTPURLResponse *response, id data, NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else{
        [self updateSchedule];
    }
}

-(NSData *)createDataForScheduleRequest{
  NSArray *ids = [self getFavoritesIds];
  NSDictionary* dataDictionary = [NSDictionary dictionaryWithObject:ids forKey:@"data"];
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:nil];
  return jsonData;
}

- (NSArray*)getAllSharedSchedules {
    return [self sharedSchedulesWithPredicate:nil];
}

- (void)removeSchedule:(DCSharedSchedule *)schedule {
  [self.workContext deleteObject:schedule];
  [[DCCoreDataStore defaultStore]
   saveMainContextWithCompletionBlock:^(BOOL isSuccess){
   }];
}
//TODO: replace methods into shredSchedule model
- (NSArray*)sharedSchedulesWithPredicate:(NSPredicate*)aPredicate {
    @try {
        NSEntityDescription* entityDescription =
        [NSEntityDescription entityForName:NSStringFromClass([DCSharedSchedule class])
                    inManagedObjectContext:self.workContext];
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entityDescription];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSPredicate* predicate = [NSPredicate
                                  predicateWithFormat:@"isMySchedule=%@", [NSNumber numberWithBool:NO]];
        [fetchRequest setPredicate:predicate];
        
        NSArray* result =
        [self.workContext executeFetchRequest:fetchRequest error:nil];
        
        if (result && [result count]) {
            return result;
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

-(NSArray *)getScheduleWithId:(NSString *)idString{
    NSEntityDescription* entityDescription =
    [NSEntityDescription entityForName:NSStringFromClass([DCSharedSchedule class])
                inManagedObjectContext:self.workContext];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate* predicate = [NSPredicate
                              predicateWithFormat:@"scheduleId=%ul", [idString integerValue]];
    [fetchRequest setPredicate:predicate];
    
    NSArray* result =
    [self.workContext executeFetchRequest:fetchRequest error:nil];
    return result;
}

-(NSArray *)getSchedulesIds{
    NSArray *schedules = [[DCMainProxy sharedProxy] getAllSharedSchedules];
    NSMutableArray* ids = [[NSMutableArray alloc] init];
    for (DCSharedSchedule* schedule in schedules) {
        [ids addObject:schedule.scheduleId];
    }
    return ids;
}

-(NSArray *)getFavoritesIds{
    NSArray* events = [self getAllFavoritesEvents];
    if(!events.count){
        return [[NSArray alloc] init];
    }
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    for(DCEvent* event in events){
        [ids addObject:event.eventId];
    }
    return ids;
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
