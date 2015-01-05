//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DCSideMenuViewController.h"
#import "DCSideMenuCell.h"
#import "DCBaseViewController.h"
#import "DCAppFacade.h"
#import "DCSideMenuType.h"
#import "DCMenuStoryboardHelper.h"
#import "DCProgramViewController.h"
#import "UIConstants.h"
#import "DCFavoritesViewController.h"

@class DCEvent;

#define kMenuItemTitle              @"MenuItemTitle"
#define kMenuItemIcon               @"MenuItemIcon"
#define kMenuItemControllerId       @"MenuItemControllerId"

@interface DCSideMenuViewController ()

@property (nonatomic, strong) NSArray *arrayOfCaptions;

// This stores the view controller instance which is placed on the menu container
@property (nonatomic, strong) DCBaseViewController *presentedController;
@property (nonatomic, strong) DCEvent *event;

@end

@implementation DCSideMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.arrayOfCaptions = @[
                                @{ kMenuItemTitle: @"Schedule",
                                   kMenuItemIcon: @"",
                                   kMenuItemControllerId: @"ProgramViewController"
                                   },
                                @{
                                    kMenuItemTitle: @"BoFs",
                                    kMenuItemIcon: @"",
                                    kMenuItemControllerId: @"ProgramViewController"
                                    },
                                @{
                                    kMenuItemTitle: @"Social Events",
                                    kMenuItemIcon: @"",
                                    kMenuItemControllerId: @""
                                    },
                                @{
                                    kMenuItemTitle: @"Speakers",
                                    kMenuItemIcon: @"",
                                    kMenuItemControllerId: @"SpeakersViewController"
                                    },
                                @{
                                    kMenuItemTitle: @"My Schedule",
                                    kMenuItemIcon: @"",
                                    kMenuItemControllerId: @"FavoritesViewController"
                                    },
                                @{
                                    kMenuItemTitle: @"Location",
                                    kMenuItemIcon: @"",
                                    kMenuItemControllerId: @"LocationViewController"
                                    },
                                @{
                                    kMenuItemTitle: @"Twitter",
                                    kMenuItemIcon: @"",
                                    kMenuItemControllerId: @""
                                    },
                                @{
                                    kMenuItemTitle: @"Points of Interest",
                                    kMenuItemIcon: @"",
                                    kMenuItemControllerId: @""
                                    },
                                @{
                                    kMenuItemTitle: @"Info",
                                    kMenuItemIcon: @"",
                                    kMenuItemControllerId: @"AboutViewController"
                                    }
                             ];
    
    //our first menu item is Program, this is actually the screen that we should see right after the login page, thats why lets just add it on top as if the user alerady selected it
    [self placeViewControllerAssociatedWithMenuItem:DCMENU_PROGRAM_ITEM];
}

- (void)placeViewControllerAssociatedWithMenuItem:(DCMenuSection)menuItem {
    NSDictionary *itemDict           = self.arrayOfCaptions[menuItem];
    NSString *storyboardControllerID = itemDict[kMenuItemControllerId];
    NSString *title                  = itemDict[kMenuItemTitle];
    
    if(storyboardControllerID && storyboardControllerID.length) {
        DCBaseViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardControllerID];
        if ([viewController isKindOfClass:[DCProgramViewController class]]) {
            [(DCProgramViewController*)viewController setEventsStrategy:[DCMenuStoryboardHelper strategyForEventMenuType:menuItem]];
        }
        
        if(self.presentedController)
            [self.presentedController.view removeFromSuperview];
        
        [[DCAppFacade shared].menuContainerViewController.view addSubview:viewController.view];
        [[DCAppFacade shared].menuContainerViewController setTitle:title];
        self.presentedController = viewController;
    }
    
    [[DCAppFacade shared].sideMenuController setMenuState:MFSideMenuStateClosed completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.event) {
        [self placeViewControllerAssociatedWithMenuItem:DCMENU_MYSCHEDULE_ITEM];
        if ([self.presentedController isMemberOfClass:[DCFavoritesViewController class]]) {
            [(DCFavoritesViewController *)self.presentedController openEvent:self.event];
        }
        self.event = nil;
    }
}

- (void)openEventFromFavorite:(DCEvent *)event
{
    self.event = event;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"SideMenuCellIdentifier";
    
    DCSideMenuCell *cell = (DCSideMenuCell*)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    
    NSDictionary *itemDict   = [self.arrayOfCaptions objectAtIndex: indexPath.row];
    cell.captionLabel.text   = itemDict[kMenuItemTitle];
    cell.leftImageView.image = [UIImage imageNamed:itemDict[kMenuItemIcon]];
    
    //Selection style
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame: cell.bounds];
    selectedBackgroundView.backgroundColor = MENU_SELECTION_COLOR;
    cell.selectedBackgroundView = selectedBackgroundView;
    
    cell.separatorView.hidden = !(indexPath.row % 3 == 2);
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self placeViewControllerAssociatedWithMenuItem:(DCMenuSection)indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return DCMENU_ITEMS_COUNT;
}

@end
