
#import <Foundation/Foundation.h>
#import "DCSideMenuType.h"
#import "DCEventStrategy.h"

@interface DCMenuStoryboardHelper : NSObject

+ (BOOL)isProgramOrBof:(DCMenuSection)menu;
+ (DCEventStrategy*)strategyForEventMenuType:(DCMenuSection)menu;

@end
