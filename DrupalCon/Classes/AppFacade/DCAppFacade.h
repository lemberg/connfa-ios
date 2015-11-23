
#import <Foundation/Foundation.h>
#import "DCMainNavigationController.h"

@interface DCAppFacade : NSObject

@property(nonatomic, weak) DCMainNavigationController* mainNavigationController;

+ (instancetype)shared;

@end
