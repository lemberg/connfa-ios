//
//  DCprogramViewController.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCBaseViewController.h"
#import "DCEventStrategy.h"

@interface DCProgramViewController : DCBaseViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) DCEventStrategy * eventsStrategy;

@end
