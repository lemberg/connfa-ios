//
//  DCFloorPlanController.m
//  DrupalCon
//
//  Created by Serhii Bocharnikov on 6/8/16.
//  Copyright © 2016 Lemberg Solution. All rights reserved.
//

#import "DCFloorPlanController.h"
#import "LESelectedActionSheetController.h"

@interface DCFloorPlanController () <LESelectedActionSheetControllerProtocol, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *floorButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
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
  self.imageView.image = [UIImage imageNamed:@"testFloor"];
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

- (void)updateMinZoomScaleForSize:(CGSize)size {
  CGFloat widthScale = size.width / self.imageView.bounds.size.width;
  CGFloat heightScale = (size.height - self.headerViewHeightConstraint.constant) / self.imageView.bounds.size.height;
  CGFloat minScale = MIN(widthScale, heightScale);
  
  self.scrollView.minimumZoomScale = minScale;
  self.scrollView.zoomScale = minScale;
}

- (void)updateConstraintsForSize:(CGSize)size {
  CGFloat yOffset = MAX(0, ((size.height - self.headerViewHeightConstraint.constant) - self.imageView.frame.size.height) / 2);
  self.imageViewTopConstraint.constant = yOffset;
  self.imageViewBottomConstraint.constant = yOffset;
  
  CGFloat xOffset = MAX(0, (size.width - self.imageView.frame.size.width) / 2);
  self.imageViewLeadingConstraint.constant = xOffset;
  self.imageViewTrailingConstraint.constant = xOffset;
  [self.view layoutIfNeeded];
}

#pragma mark - Overrides

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [self.view layoutIfNeeded];
  [self updateMinZoomScaleForSize:self.view.bounds.size];
  [self updateConstraintsForSize:self.view.bounds.size];
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

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return self.imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self updateConstraintsForSize:self.view.bounds.size];
}

@end
