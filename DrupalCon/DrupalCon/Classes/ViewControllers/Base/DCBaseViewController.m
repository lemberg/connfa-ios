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

-(void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];

    if (self.navigatorBarStyle == EBaseViewControllerNatigatorBarStyleNormal)
    {
        self.navigationController.navigationBar.barTintColor = NAV_BAR_COLOR;
        NSDictionary *textAttributes = NAV_BAR_TITLE_ATTRIBUTES;
        
        
        self.navigationController.navigationBar.titleTextAttributes = textAttributes;
        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        UIBarButtonItem * backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(onBack)];
        self.navigationItem.backBarButtonItem = backBtn;
        
        if (self.navigationController.viewControllers.count != 1)
        // for all root view controllers 'topItem' is Title not Back Button
        {
            self.navigationController.navigationBar.topItem.title = @"Back";
        }
    }
    else if (self.navigatorBarStyle == EBaseViewControllerNatigatorBarStyleTransparrent)
    {
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;

    }
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];

}

- (void)onBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
