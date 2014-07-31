//
//  DCAppFacade.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/31/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCMenuContainerViewController.h"
#import "MFSideMenu.h"

@interface DCAppFacade : NSObject

@property (nonatomic, weak) DCMenuContainerViewController *menuContainerViewController;
@property (nonatomic, weak) MFSideMenuContainerViewController *sideMenuController;
+(instancetype)shared;

@end
