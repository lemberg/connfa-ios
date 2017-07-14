
#import <UIKit/UIKit.h>
#import "DCBaseViewController.h"
#import "DCEvent+CoreDataProperties.h"


typedef void (^CloseCallback)();
@class  DCProgram, DCBof;

@interface DCEventDetailViewController
    : DCBaseViewController<UITableViewDataSource,
                           UITableViewDelegate,
                           UIWebViewDelegate,
                           UIScrollViewDelegate>

@property(nonatomic, strong) DCEvent* event;
@property(nonatomic, strong) CloseCallback closeCallback;

- (instancetype)initWithEvent:(DCEvent*)event;

@end
