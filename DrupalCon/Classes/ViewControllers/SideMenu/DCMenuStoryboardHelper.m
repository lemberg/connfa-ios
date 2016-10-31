
#import "DCMenuStoryboardHelper.h"

@implementation DCMenuStoryboardHelper

+ (BOOL)isProgramOrBof:(DCMenuSection)menu {
  return (menu == DCMENU_PROGRAM_ITEM || menu == DCMENU_BOFS_ITEM);
}

+ (DCEventStrategy*)strategyForEventMenuType:(DCMenuSection)menu {
  EDCEventStrategy eStrategy = EDCEventStrategyPrograms;
  switch (menu) {
    case DCMENU_PROGRAM_ITEM:
      eStrategy = EDCEventStrategyPrograms;
      break;

    case DCMENU_BOFS_ITEM:
      eStrategy = EDCEventStrategyBofs;
      break;
    case DCMENU_SOCIAL_EVENTS_ITEM:
      eStrategy = EDCEventStrategySocialEvents;
      break;
    case DCMENU_MYSCHEDULE_ITEM:
      eStrategy = EDCEeventStrategyFavorites;
    default:
      break;
  }
  DCEventStrategy* strategy =
      [[DCEventStrategy alloc] initWithStrategy:eStrategy];
  return strategy;
}

@end
