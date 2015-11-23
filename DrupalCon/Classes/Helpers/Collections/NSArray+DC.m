
#import "NSArray+DC.h"
#import "DCTime+DC.h"
#import "DCTimeRange+DC.h"
#import "DCEvent+DC.h"
#import "NSDictionary+DC.h"

@implementation NSArray (DC)

- (NSArray*)objectsFromDictionaries {
  if (self.count > 0) {
    if ([self.firstObject isKindOfClass:[NSDictionary class]]) {
      NSArray* keys = [(NSDictionary*)self.firstObject allKeys];
      if (keys.count == 1) {
        NSString* key = keys.firstObject;
        NSMutableArray* result =
            [[NSMutableArray alloc] initWithCapacity:self.count];
        for (NSDictionary* dict in self) {
          [result addObject:dict[key]];
        }
        return result;
      }
    }
  }
  NSLog(@"WRONG! method used");
  return self;
}

- (NSArray*)sortedByEventId {
  if (self.count) {
    if ([self.firstObject isKindOfClass:[DCEvent class]]) {
      NSSortDescriptor* sortDescriptor =
          [[NSSortDescriptor alloc] initWithKey:kDCEventIdKey ascending:YES];
      return [self sortedArrayUsingDescriptors:@[ sortDescriptor ]];
    }
  }
  NSLog(@"WRONG! array for sort. events by id");
  return self;
}

- (NSArray*)sortedByKey:(NSString*)key ascending:(BOOL)ascending {
  if (self.count) {
    NSSortDescriptor* sortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
    return [self sortedArrayUsingDescriptors:@[ sortDescriptor ]];
  }
  NSLog(@"WRONG! array for sort. events by id");
  return self;
}

- (NSArray*)sortedByKey:(NSString*)key {
  return [self sortedByKey:key ascending:YES];
}

- (NSArray*)sortedDates {
  if (self.count) {
    if ([self.firstObject isKindOfClass:[NSDate class]]) {
      NSSortDescriptor* descriptor =
          [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
      return [self sortedArrayUsingDescriptors:@[ descriptor ]];
    }
  }
  NSLog(@"WRONG! array for sort. dates");
  return self;
}

- (NSArray*)sortedByStartHour {
  if (self.count) {
    if ([self.firstObject isKindOfClass:[DCTimeRange class]]) {
      NSSortDescriptor* descriptor = [NSSortDescriptor
          sortDescriptorWithKey:@"self"
                      ascending:YES
                     comparator:^NSComparisonResult(id obj1, id obj2) {
                       NSDate* fromTime1 = [(DCTimeRange*)obj1 from];
                       NSDate* fromTime2 = [(DCTimeRange*)obj2 from];

                       NSDate* toTime1 = [(DCTimeRange*)obj1 to];
                       NSDate* toTime2 = [(DCTimeRange*)obj2 to];

                       NSComparisonResult fromResult =
                           [fromTime1 compare:fromTime2];  //[self
                       // DC_checkTime1:time1
                       // time2:time2];

                       NSComparisonResult toResult = [toTime1 compare:toTime2];
                       if (fromResult == NSOrderedSame &&
                           toResult == NSOrderedSame) {
                         return fromResult;
                       }
                       if (fromResult == NSOrderedSame &&
                           toResult != NSOrderedSame) {
                         return toResult;
                       }

                       return fromResult;
                     }];
      return [self sortedArrayUsingDescriptors:@[ descriptor ]];
    }
  }
  NSLog(@"WRONG! array for sort. timeRange");
  return self;
}

- (NSArray*)eventsForTimeRange:(DCTimeRange*)timeRange {
  if (self.count) {
    if ([self.firstObject isKindOfClass:[DCEvent class]]) {
      NSPredicate* predicate = [NSPredicate
          predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
            return [(DCTimeRange*)[(DCEvent*)evaluatedObject timeRange]
                isEqualTo:timeRange];
          }];

      return [self filteredArrayUsingPredicate:predicate];
    }
  }
  NSLog(@"WRONG! array for sort. dates");
  return self;
}

#pragma mark - private

- (NSArray*)dictionaryByReplacingNullsWithStrings {
  NSMutableArray* replaced = [self mutableCopy];
  const id nul = [NSNull null];
  const NSString* blank = @"";
  for (int idx = 0; idx < [replaced count]; idx++) {
    id object = [replaced objectAtIndex:idx];
    if (object == nul)
      [replaced replaceObjectAtIndex:idx withObject:blank];
    else if ([object isKindOfClass:[NSDictionary class]])
      [replaced
          replaceObjectAtIndex:idx
                    withObject:[object dictionaryByReplacingNullsWithStrings]];
    else if ([object isKindOfClass:[NSArray class]])
      [replaced
          replaceObjectAtIndex:idx
                    withObject:[object dictionaryByReplacingNullsWithStrings]];
  }
  return [replaced copy];
}
@end
