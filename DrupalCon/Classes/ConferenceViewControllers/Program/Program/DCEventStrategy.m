
#import "DCEventStrategy.h"
#import "DCMainProxy+Additions.h"
#import "DCSocialEvent+DC.h"

@interface DCEventStrategy ()

// Only for favorite events
@property(nonatomic, strong) UIColor* leftSectionContainerColor;

@property(nonatomic, strong) UIColor* favoriteEventTextColor;

@end

@implementation DCEventStrategy

- (instancetype)initWithStrategy:(EDCEventStrategy)strategy {
  self = [super init];
  if (self) {
    _predicate = nil;

    _strategy = strategy;
    _favoriteEventTextColor = [DCAppConfiguration favoriteEventColor];

    switch (_strategy) {
      case EDCEventStrategyPrograms:
        _eventClass = [DCMainEvent class];
        _predicate = [self eventStretegyPredicate];
        break;

      case EDCEventStrategyBofs:
        _eventClass = [DCBof class];
        break;
      case EDCEventStrategySocialEvents:
        _eventClass = [DCSocialEvent class];

        break;
      case EDCEeventStrategyFavorites:
        _eventClass = [DCEvent class];
        _predicate = [self favoritesPredicate];
        _leftSectionContainerColor = [UIColor whiteColor];
        break;
      default:
        break;
    }
  }
  return self;
}

- (UIColor*)favoriteTextColor {
  return self.favoriteEventTextColor;
}

- (UIColor*)leftSectionContainerColor {
  return _leftSectionContainerColor;
}

- (BOOL)isEnableFilter {
  return self.strategy == EDCEventStrategyPrograms &&
         [DCAppConfiguration isFilterEnable];
}

- (NSPredicate*)eventStretegyPredicate {
  NSPredicate* levelPredicate =
      [NSPredicate predicateWithFormat:@"level.selectedInFilter == true"];
  NSPredicate* trackPredicate =
      [NSPredicate predicateWithFormat:@"ANY tracks.selectedInFilter == true"];

  NSPredicate* mergedPredicate = [NSCompoundPredicate
      andPredicateWithSubpredicates:@[ levelPredicate, trackPredicate ]];
  return mergedPredicate;
}

- (NSPredicate*)favoritesPredicate {
  return [NSPredicate
      predicateWithFormat:@"favorite=%@", [NSNumber numberWithBool:YES]];
}

- (void)dealloc {
  self.predicate = nil;
}

- (NSArray*)days {
  return [[DCMainProxy sharedProxy] daysForClass:_eventClass
                                       predicate:self.predicate];
}

- (NSArray*)eventsForDay:(NSDate*)day {
  return [[DCMainProxy sharedProxy] eventsForDay:day
                                        forClass:_eventClass
                                       predicate:self.predicate];
}

- (NSArray*)uniqueTimeRangesForDay:(NSDate*)day {
  return [[DCMainProxy sharedProxy] uniqueTimeRangesForDay:day
                                                  forClass:_eventClass
                                                 predicate:self.predicate];
}

@end
