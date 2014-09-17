//
//  DCSideMenuViewController.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCSideMenuViewController.h"
#import "DCSideMenuCell.h"
#import "DCBaseViewController.h"
#import "DCAppFacade.h"
#import "DCSideMenuType.h"
#import "DCMenuImage.h"
#import "DCMenuStoryboardHelper.h"
#import "DCProgramViewController.h"
#import "UIConstants.h"
#import "DCFavoritesViewController.h"

#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE
@class DCEvent;

@interface DCSideMenuViewController ()
@property (nonatomic, strong) NSArray *arrayOfCaptions;

// This stores the view controller instance which is placed on the menu container
@property (nonatomic, strong) DCBaseViewController *presentedController;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *avatarTopSpaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewTopContraint;
@property (nonatomic, strong) DCEvent *event;
@end

@implementation DCSideMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.arrayOfCaptions) {
        self.arrayOfCaptions = [NSArray arrayWithObjects: @"Schedule", @"BoFs", @"Speakers", @"Location", @"About", @"My Schedule", nil];
    }
    
    if(!isiPhone5) {
        self.tableViewTopContraint.constant = 0;
        self.avatarTopSpaceConstraint.constant = 6;
    }
    
    //our first menu item is Program, this is actually the screen that we should see right after the login page, thats why lets just add it on top as if the user alerady selected it
    
    [self placeViewControllerAssociatedWithMenuItem: DCMENU_PROGRAM_ITEM];
}

-(void) placeViewControllerAssociatedWithMenuItem: (DCMenuSection) menuItem {
    NSString *storyboardControllerID = [DCMenuStoryboardHelper viewControllerStoryboardIDFromMenuType: menuItem];
    
    NSString *title = [DCMenuStoryboardHelper titleForMenuType: menuItem];
    
    if(storyboardControllerID) {
        DCBaseViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier: storyboardControllerID];
        if ([viewController isKindOfClass:[DCProgramViewController class]])
        {
            [(DCProgramViewController*)viewController setEventsStrategy:[DCMenuStoryboardHelper strategyForEventMenuType:menuItem]];
        }
        
        if(self.presentedController)
            [self.presentedController.view removeFromSuperview];

        
        [[DCAppFacade shared].menuContainerViewController.view addSubview: viewController.view];
        [[DCAppFacade shared].menuContainerViewController setTitle: title];
        self.presentedController = viewController;
    }
    
    [[DCAppFacade shared].sideMenuController setMenuState: MFSideMenuStateClosed completion: nil];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"SideMenuCellIdentifier";
    
    DCSideMenuCell *cell = (DCSideMenuCell*)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    
    
    DCMenuImage *menuImage = [[DCMenuImage alloc] initWithMenuType: (int)indexPath.row];
    cell.leftImageView.image = menuImage;
    cell.captionLabel.text = [self.arrayOfCaptions objectAtIndex: indexPath.row];
    
    //Selection style
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame: cell.bounds];
    selectedBackgroundView.backgroundColor = MENU_SELECTION_COLOR;
    cell.selectedBackgroundView = selectedBackgroundView;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self placeViewControllerAssociatedWithMenuItem: (DCMenuSection)indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return DCMENU_ITEMS_COUNT;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}



@end
