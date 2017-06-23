
#import "DCEventStrategy.h"
#import "DCMainProxy+Additions.h"
#import "DCSocialEvent+DC.h"

@interface DCEventStrategy ()

// Only for favorite events
@property(nonatomic, strong) UIColor* leftSectionContainerColor;

@property(nonatomic, strong) UIColor* favoriteEventTextColor;

@end

@implementation DCEventStrategy

- (instancetype)initWithStrategy:(EDCEventStrategy)strategy andSchedule:(DCSharedSchedule *)schedule{
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
        _predicate = [self eventStretegyPredicate];
        break;
      case EDCEventStrategySocialEvents:
        _eventClass = [DCSocialEvent class];
        _predicate = [self eventStretegyPredicate];
        break;
            
      case EDCEeventStrategyFavorites:
        _eventClass = [DCEvent class];
        _predicate = [self favoritesPredicate];
        _leftSectionContainerColor = [UIColor whiteColor];
        break;
      case EDCEventStrategySharedSchedule:
        _eventClass = [DCEvent class];
        _schedule = schedule;
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
    BOOL result = NO;
    if ((self.strategy == EDCEventStrategyPrograms || self.strategy == EDCEventStrategyBofs || self.strategy == EDCEventStrategySocialEvents) &&
        [DCAppConfiguration isFilterEnable]) {
        result = YES;
    }

  return result;
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
                                   sharedSchedule:self.schedule
                                       predicate:self.predicate];
}

- (NSArray*)eventsForDay:(NSDate*)day {
  return [[DCMainProxy sharedProxy] eventsForDay:day
                                        forClass:_eventClass
                                  sharedSchedule: self.schedule
                                       predicate:self.predicate];
}

- (NSArray*)uniqueTimeRangesForDay:(NSDate*)day {
  return [[DCMainProxy sharedProxy] uniqueTimeRangesForDay:day
                                                  forClass:_eventClass
                                            sharedSchedule:self.schedule
                                                 predicate:self.predicate];
}

@end
