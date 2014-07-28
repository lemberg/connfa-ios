//
//  DCMenuContainerViewController.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import "DCMenuContainerViewController.h"
#import "MFSideMenu.h"
#import "DCAppFacade.h"
@interface DCMenuContainerViewController ()
@end

@implementation DCMenuContainerViewController

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
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self setupMenuBarButtonItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}


- (void)setupMenuBarButtonItems {
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    UIBarButtonItem * item = [[UIBarButtonItem alloc]
                              initWithImage:[UIImage imageNamed:@"menu-icon"] style:
     UIBarButtonItemStyleBordered
     target:self
     action:@selector(leftSideMenuButtonPressed:)];
    return item;
}



- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStyleBordered
                                           target:self action:@selector(backButtonPressed:)];
}


#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

-(IBAction) pushNew:(id)sender {
    DCMenuContainerViewController *contaienrController = [self.storyboard instantiateViewControllerWithIdentifier:@"SideMenuContainer"];
    
    [self.navigationController pushViewController:contaienrController animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
