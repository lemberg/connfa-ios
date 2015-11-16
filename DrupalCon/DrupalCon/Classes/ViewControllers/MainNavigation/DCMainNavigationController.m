/**********************************************************************************
 *                                                                           
 *  The MIT License (MIT)
 *  Copyright (c) 2015 Lemberg Solutions Limited
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the 
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *   The above copyright notice and this permission notice shall be included in
 *   all  copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM,  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 *  IN THE SOFTWARE.
 *
 *                                                                           
 *****************************************************************************/



#import "DCMainNavigationController.h"
#import "DCSideMenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "DCAppFacade.h"
#import "DCLimitedNavigationController.h"

@interface DCMainNavigationController ()

@property(nonatomic, weak) DCSideMenuViewController* sideMenuController;

@end

@implementation DCMainNavigationController

- (void)viewDidLoad {
  [super viewDidLoad];

  [DCAppFacade shared].mainNavigationController = self;

  return;
}

- (void)openEventFromFavoriteController:(DCEvent*)event {
  [self goToSideMenuContainer:NO];
  [self.sideMenuController openEventFromFavorite:event];
}

- (void)goToSideMenuContainer:(BOOL)animated {
  DCSideMenuViewController* sideMenuViewController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"SideMenuViewController"];

  self.sideMenuController = sideMenuViewController;

  MFSideMenuContainerViewController* container =
      [MFSideMenuContainerViewController
          containerWithCenterViewController:nil
                     leftMenuViewController:self.sideMenuController
                    rightMenuViewController:nil];
  sideMenuViewController.sideMenuContainer = container;

  [self pushViewController:container animated:animated];
}

- (UIViewController*)childViewControllerForStatusBarStyle {
  if ([self.visibleViewController
          isKindOfClass:[MFSideMenuContainerViewController class]]) {
    MFSideMenuContainerViewController* topController =
        (MFSideMenuContainerViewController*)self.visibleViewController;

    UIViewController* menuController = topController.leftMenuViewController;
    UIViewController* sideController = topController.centerViewController;

    // asks for Statur Bar for SideMenuController
    if (menuController && [sideController isKindOfClass:[NSNull class]])
      return menuController;

    if (topController.menuState == MFSideMenuStateClosed) {
      if ([sideController isKindOfClass:[UINavigationController class]]) {
        // asks for Statur Bar for SideMenu Item viewController
        return [(UINavigationController*)sideController visibleViewController];
      }
    } else {
      return menuController;
    }
  } else {
    return self.visibleViewController;
  }

  return self.visibleViewController;
}

@end
