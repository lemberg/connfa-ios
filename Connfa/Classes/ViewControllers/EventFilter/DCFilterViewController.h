
#import <UIKit/UIKit.h>
#import "DCBaseViewController.h"
#import "DCEventFilterCell.h"

@protocol DCFilterViewControllerDelegate<NSObject>

- (void)filterControllerWillDismiss:(BOOL)cancel;

@end

@interface DCFilterViewController
    : DCBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) id<DCFilterViewControllerDelegate> delegate;

@end
