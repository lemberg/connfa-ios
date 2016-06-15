//
//  DCFloorPlanController.m
//  DrupalCon
//
//  Created by Serhii Bocharnikov on 6/8/16.
//  Copyright © 2016 Lemberg Solution. All rights reserved.
//

#import "DCFloorPlanController.h"
#import "LESelectedActionSheetController.h"
#import "DCHousePlan.h"
#import "UIImageView+WebCache.h"

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
@property (strong, nonatomic) NSArray *floorTitles;
@property (nonatomic) NSUInteger selectedActionIndex;
@property(nonatomic) __block DCMainProxyState previousState;

@end

@implementation DCFloorPlanController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
  
  self.imageView.image = [UIImage imageNamed:@"testFloor"];
  
  [self configureTapGestureRecognizers];
  
  [self checkProxyState];
}

#pragma mark - Private

- (void)checkProxyState {
  [[DCMainProxy sharedProxy]
   setDataReadyCallback:^(DCMainProxyState mainProxyState) {
     dispatch_async(dispatch_get_main_queue(), ^{
       NSLog(@"Data ready callback %d", mainProxyState);
       if (!self.previousState) {
         [self reloadData];
         self.previousState = mainProxyState;
       }
       
       if (mainProxyState == DCMainProxyStateDataUpdated) {
         [self reloadData];
       }
     });
   }];
}

- (void)reloadData {
  self.floors = [[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCHousePlan class] inMainQueue:YES];
  
  NSMutableArray *floorTitles = [[NSMutableArray alloc] init];
  for (DCHousePlan *floorPlan in self.floors) {
    [floorTitles addObject:floorPlan.name];
  }
  self.floorTitles = [NSArray arrayWithArray:floorTitles];
  [self.floorButton setTitle:floorTitles[self.selectedActionIndex] forState:UIControlStateNormal];
  [self reloadImage];
}

- (void)reloadImage {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  DCHousePlan *floorPlan = self.floors[self.selectedActionIndex];
  NSURL *URL = [NSURL URLWithString:floorPlan.imageURL];
  [self.imageView sd_setImageWithURL:URL placeholderImage:nil
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  }];
}

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

- (void)configureTapGestureRecognizers {
  UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
  doubleTapRecognizer.numberOfTapsRequired = 2;
  doubleTapRecognizer.numberOfTouchesRequired = 1;
  [self.scrollView addGestureRecognizer:doubleTapRecognizer];
  
  UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
  twoFingerTapRecognizer.numberOfTapsRequired = 1;
  twoFingerTapRecognizer.numberOfTouchesRequired = 2;
  [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer *)recognizer {
  CGPoint pointInView = [recognizer locationInView:self.imageView];
  CGFloat newZoomScale = self.scrollView.zoomScale * 1.5;
  newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
  CGSize scrollViewSize = self.scrollView.bounds.size;
  CGFloat w = scrollViewSize.width / newZoomScale;
  CGFloat h = scrollViewSize.height / newZoomScale;
  CGFloat x = pointInView.x - (w / 2.0);
  CGFloat y = pointInView.y - (h / 2.0);
  CGRect rectToZoomTo = CGRectMake(x, y, w, h);
  [self.scrollView zoomToRect:rectToZoomTo animated:YES];
  [self updateConstraintsForSize:self.view.bounds.size];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
  CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
  newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
  [self.scrollView setZoomScale:newZoomScale animated:YES];
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
  return self.floorTitles[index];
}

- (void)performActionAtIndex:(NSInteger)index {
  self.selectedActionIndex = index;
  [self.floorButton setTitle:self.floorTitles[index] forState:UIControlStateNormal];
  [self reloadImage];
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return self.imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self updateConstraintsForSize:self.view.bounds.size];
}

@end
