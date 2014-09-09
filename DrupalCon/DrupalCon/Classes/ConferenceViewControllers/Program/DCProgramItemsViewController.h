//
//  DCProgramItemsViewController.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCEventStrategy.h"

@interface DCProgramItemsViewController : UIViewController

@property (nonatomic) int pageIndex;
@property (nonatomic, strong) NSArray* events;
@property (nonatomic, strong) NSArray* timeslots;
@property (nonatomic, strong) DCEventStrategy * eventsStrategy;

@end
