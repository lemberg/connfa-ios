//
//  DCSideMenuViewController.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DCEvent;
@interface DCSideMenuViewController : UIViewController<UITableViewDelegate>
- (void)openEventFromFavorite:(DCEvent *)event;
@end
