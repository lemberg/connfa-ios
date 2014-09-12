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

@property (nonatomic) NSInteger pageIndex;

@property (nonatomic, strong) NSArray* timeslots;
// timeslot element : dictionary "time slot value" : NSArray of events;

@property (nonatomic, strong) DCEventStrategy * eventsStrategy;

@end
