//
//  DCFloorPlanController.m
//  DrupalCon
//
//  Created by Serhii Bocharnikov on 6/8/16.
//  Copyright © 2016 Lemberg Solution. All rights reserved.
//

#import "DCFloorPlanController.h"
#import "LESelectedActionSheetController.h"

@interface DCFloorPlanController () <LESelectedActionSheetControllerProtocol>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *floorButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSArray *floors;
@property (nonatomic) NSUInteger selectedActionIndex;

@end

@implementation DCFloorPlanController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
  
  // Test data
  self.floors = @[@"Floor1", @"Floor2", @"Floor3", @"Floor4"];
  self.selectedActionIndex = 2;
  [self.floorButton setTitle:self.floors[self.selectedActionIndex] forState:UIControlStateNormal];
}

#pragma mark - Private

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)showActionSheet {
  LESelectedActionSheetController *actionSheetController = [[LESelectedActionSheetController alloc] init];
  actionSheetController.delegate = self;
  actionSheetController.selectedItemIndex = self.selectedActionIndex;
  [self presentViewController:actionSheetController animated:YES completion:nil];

}

#pragma mark - IBAction

- (IBAction)didTouchFloorButton:(UIButton *)sender {
  [self showActionSheet];
}

#pragma mark - LESelectedActionSheetControllerProtocol

- (NSInteger)numberOfActions {
  return self.floors.count;
}

- (NSString *)titleForActionAtIndex:(NSInteger)index {
  return self.floors[index];
}

- (void)performActionAtIndex:(NSInteger)index {
  self.selectedActionIndex = index;
  [self.floorButton setTitle:self.floors[index] forState:UIControlStateNormal];
}

@end
