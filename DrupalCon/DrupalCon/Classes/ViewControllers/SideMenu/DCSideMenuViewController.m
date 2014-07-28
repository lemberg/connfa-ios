//
//  DCSideMenuViewController.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import "DCSideMenuViewController.h"
#import "DCSideMenuCell.h"
#import "DCBaseViewController.h"
#import "DCAppFacade.h"

typedef NS_ENUM (int, DCMenuSection) {
    DCMENU_PROGRAM_ITEM = 0,
    DCMENU_SPEAKERS_ITEM = 1,
    DCMENU_LOCATION_ITEM = 2,
    DCMENU_ABOUT_ITEM = 3,
    DCMENU_MYSCHEDULE_ITEM = 4,
    DCMENU_ITEMS_COUNT
};

@interface DCSideMenuViewController ()
@property (nonatomic, strong) NSArray *arrayOfCaptions;

// This stores the view controller instance which is placed on the menu container
@property (nonatomic, weak) DCBaseViewController *presentedController;
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
        self.arrayOfCaptions = [NSArray arrayWithObjects: @"Program", @"Speakers", @"Locations", @"About", @"My Schedule", nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"SideMenuCellIdentifier";
    
    DCSideMenuCell *cell = (DCSideMenuCell*)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    
    cell.captionLabel.text = [self.arrayOfCaptions objectAtIndex: indexPath.row];
    
    //Selection style
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame: cell.bounds];
    selectedBackgroundView.backgroundColor = [UIColor colorWithRed: 52./255. green: 52./255. blue: 59./255. alpha: 1.0];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *storyboardControllerID = @"";
    if(indexPath.row == DCMENU_PROGRAM_ITEM)
        storyboardControllerID = @"ProgramViewController";
    
    if(indexPath.row == DCMENU_SPEAKERS_ITEM)
        storyboardControllerID = @"SpeakersViewController";
      
    
    if(indexPath.row == DCMENU_LOCATION_ITEM) {
       
    }
    if(indexPath.row == DCMENU_ABOUT_ITEM) {
        
    }
    if(indexPath.row == DCMENU_MYSCHEDULE_ITEM) {
       
    }
    
    DCBaseViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier: storyboardControllerID];
    
    if(self.presentedController)
      [self.presentedController.view removeFromSuperview];

    [[DCAppFacade shared].menuContainerViewController.view addSubview: viewController.view];
    [[DCAppFacade shared].sideMenuController setMenuState: MFSideMenuStateClosed completion: nil];
    self.presentedController = viewController;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return DCMENU_ITEMS_COUNT;
}



@end
