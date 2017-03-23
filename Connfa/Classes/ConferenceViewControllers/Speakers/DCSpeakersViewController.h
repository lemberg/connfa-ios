
#import "DCBaseViewController.h"

@interface DCSpeakersViewController
    : DCBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSArray* speakers;

@end
