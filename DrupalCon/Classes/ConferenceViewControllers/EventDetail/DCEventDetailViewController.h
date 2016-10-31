
#import <UIKit/UIKit.h>
#import "DCBaseViewController.h"


typedef void (^CloseCallback)();
@class DCEvent, DCProgram, DCBof;

@interface DCEventDetailViewController
    : DCBaseViewController<UITableViewDataSource,
                           UITableViewDelegate,
                           UIWebViewDelegate,
                           UIScrollViewDelegate>

@property(nonatomic, strong) DCEvent* event;
@property(nonatomic, strong) CloseCallback closeCallback;

- (instancetype)initWithEvent:(DCEvent*)event;

@end
