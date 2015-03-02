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

@property (nonatomic, strong) DCEvent *event;

@end


@implementation DCSideMenuViewController

#pragma mark - View lifecycle

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
    [self showViewControllerAssociatedWithMenuItem:DCMENU_PROGRAM_ITEM];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.event) {
        [self showViewControllerAssociatedWithMenuItem:DCMENU_MYSCHEDULE_ITEM];
        if ([self.sideMenuContainer.centerViewController isMemberOfClass:[DCFavoritesViewController class]]) {
            [(DCFavoritesViewController *)self.sideMenuContainer.centerViewController openEvent:self.event];
        }
        self.event = nil;
    }
}

#pragma mark - Private

- (void) showViewControllerAssociatedWithMenuItem:(DCMenuSection)menuItem
{
    NSString *storyboardControllerID = self.arrayOfCaptions[menuItem][kMenuItemControllerId];
    NSAssert(storyboardControllerID.length, @"No Storyboard ID for Menu item view controller");
    
    DCBaseViewController* rootMenuVC = [self getViewController:menuItem];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController: rootMenuVC];
    [self arrangeNavigationBarForController: rootMenuVC menuItem:menuItem];
    
    self.sideMenuContainer.centerViewController = navigationController;
    [self.sideMenuContainer setMenuState:MFSideMenuStateClosed completion:nil];
}

- (void) arrangeNavigationBarForController:(DCBaseViewController*)aController menuItem:(DCMenuSection)menuItem
{
        // add proper Title
    NSString *title = self.arrayOfCaptions[menuItem][kMenuItemTitle];
    aController.navigationItem.title = title;
    
        // add left Menu button to all Controllers
    UIImage *image = [UIImage imageNamed:@"menu-icon"];
    UIButton *button = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, image.size.width, image.size.height)];
    [button setBackgroundImage: image forState: UIControlStateNormal];
    [button addTarget: self action:@selector(leftSideMenuButtonPressed:) forControlEvents: UIControlEventTouchUpInside];
    aController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: button];
}

- (void)openEventFromFavorite:(DCEvent *)event
{
    self.event = event;
}

#pragma mark - User actions

- (void)leftSideMenuButtonPressed:(id)sender
{
    [self.sideMenuContainer toggleLeftSideMenuCompletion:nil];
}

- (DCBaseViewController*) getViewController:(DCMenuSection)menuItem
{
    NSString *storyboardId = self.arrayOfCaptions[menuItem][kMenuItemControllerId];
    DCBaseViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier: storyboardId];

    if ([viewController isKindOfClass:[DCProgramViewController class]])
    {
        [(DCProgramViewController*)viewController setEventsStrategy:[DCMenuStoryboardHelper strategyForEventMenuType:menuItem]];
    }

    return viewController;
}

#pragma mark - UITableView delegate

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
    [self showViewControllerAssociatedWithMenuItem:(DCMenuSection)indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return DCMENU_ITEMS_COUNT;
}

@end
