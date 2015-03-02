//
//  DCMainNavigationController.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 2/27/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCMainNavigationController.h"
#import "DCSideMenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "DCAppFacade.h"


@interface DCMainNavigationController ()

@property (nonatomic, weak) DCSideMenuViewController* sideMenuController;

@end


@implementation DCMainNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [DCAppFacade shared].mainNavigationController = self;
}

- (void)openEventFromFavoriteController:(DCEvent *)event
{
    [self goToSideMenuContainer: NO];
    [self.sideMenuController openEventFromFavorite:event];
}

- (void) goToSideMenuContainer:(BOOL)animated
{
    DCSideMenuViewController *sideMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
    sideMenuViewController.sideMenuContainer = [MFSideMenuContainerViewController containerWithCenterViewController: nil
                                                                                             leftMenuViewController: sideMenuViewController
                                                                                            rightMenuViewController: nil];
    [self pushViewController:sideMenuViewController.sideMenuContainer animated: animated];
}

@end
