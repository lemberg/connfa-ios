
#import <Foundation/Foundation.h>
#import "DCEvent+DC.h"
#import "DCMainEvent+DC.h"
#import "DCBof.h"

typedef enum {
  EDCEventStrategyPrograms = 0,
  EDCEventStrategyBofs = 1,
  EDCEventStrategySocialEvents,
  EDCEeventStrategyFavorites,
  EDCEventStrategySharedSchedule
} EDCEventStrategy;


@interface DCEventStrategy : NSObject

@property(nonatomic) EDCEventStrategy strategy;
@property(nonatomic, strong) NSPredicate* predicate;
@property(nonatomic, strong) Class eventClass;
@property(nonatomic, strong) DCSharedSchedule* schedule;

- (instancetype)initWithStrategy:(EDCEventStrategy)strategy andSchedule:(DCSharedSchedule *)schedule;

- (UIColor*)favoriteTextColor;
// Only for favorite events
- (UIColor*)leftSectionContainerColor;
- (NSArray*)days;
- (NSArray*)eventsForDay:(NSDate*)day;
- (NSArray*)uniqueTimeRangesForDay:(NSDate*)day;
- (BOOL)isEnableFilter;

@end
