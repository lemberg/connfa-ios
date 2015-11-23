
#import <UIKit/UIKit.h>
#import "DCBaseViewController.h"

@class DCSpeaker;
typedef void (^CloseCallback)();

@interface DCSpeakersDetailViewController
    : DCBaseViewController<UITableViewDataSource,
                           UITableViewDelegate,
                           UIScrollViewDelegate>

@property(nonatomic, strong) DCSpeaker* speaker;
@property(nonatomic, strong) CloseCallback closeCallback;

@end
