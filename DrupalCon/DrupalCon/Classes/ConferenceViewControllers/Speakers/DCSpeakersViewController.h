//
//  DCSpeakersViewController.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCBaseViewController.h"

@interface DCSpeakersViewController : DCBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray * speakers;

@end
