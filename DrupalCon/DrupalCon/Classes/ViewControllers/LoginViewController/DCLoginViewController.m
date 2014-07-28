//
//  ViewController.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import "DCLoginViewController.h"
#import "DCSideMenuViewController.h"
#import "MFSideMenu.h"
#import "DCMenuContainerViewController.h"
#import "DCAppFacade.h"

@interface DCLoginViewController ()

@end


@implementation DCLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
}

-(IBAction) loginButtonCLicked:(id)sender {
    DCSideMenuViewController *sideMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
    
    UINavigationController *containerController = [self menuNavigationController];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:containerController
                                                    leftMenuViewController: sideMenuViewController
                                                    rightMenuViewController: nil];
    
    [DCAppFacade shared].sideMenuController = container;
    UINavigationController *navigationController = self.navigationController;
    [navigationController pushViewController:container  animated: YES];
}

- (UINavigationController *)menuNavigationController {
    return [[UINavigationController alloc]
            initWithRootViewController:[self containerController]];
}

- (DCMenuContainerViewController *)containerController {
    DCMenuContainerViewController *container = [self.storyboard instantiateViewControllerWithIdentifier: @"SideMenuContainer"];
    
    [DCAppFacade shared].menuContainerViewController = container;
    return container;
}


@end
