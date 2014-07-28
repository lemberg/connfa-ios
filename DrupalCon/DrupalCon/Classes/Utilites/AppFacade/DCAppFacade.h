//
//  DCAppFacade.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFSideMenu.h"
@interface DCAppFacade : NSObject

+(instancetype)shared;
@property (nonatomic, weak) UIViewController *menuContainerViewController;
@property (nonatomic, weak) MFSideMenuContainerViewController *sideMenuController;
@end
