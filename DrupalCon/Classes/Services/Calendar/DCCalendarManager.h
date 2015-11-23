
#import <Foundation/Foundation.h>
#import "DCEvent.h"

@class DCEvent;

@interface DCCalendarManager : NSObject

- (void)addEventWithItem:(DCEvent*)event interval:(int)minutesBefore;
- (void)removeEventOfItem:(DCEvent*)event;

@end
