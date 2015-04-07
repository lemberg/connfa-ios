//
//  DCMainNavigationController.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 2/27/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCEvent;
@interface DCMainNavigationController : UINavigationController

- (void)openEventFromFavoriteController:(DCEvent *)event;
- (void) goToSideMenuContainer:(BOOL) animated;

@end
