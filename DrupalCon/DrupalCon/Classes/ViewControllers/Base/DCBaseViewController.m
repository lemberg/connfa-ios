//
//  DCBaseViewController.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCBaseViewController.h"
#import "UIConstants.h"

@interface DCBaseViewController ()

@end

@implementation DCBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    self.navigationController.navigationBar.barTintColor = NAV_BAR_COLOR;
    NSDictionary *textAttributes = NAV_BAR_TITLE_ATTRIBUTES;
    

    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    self.navigationController.navigationBar.translucent = NO;
}

@end
