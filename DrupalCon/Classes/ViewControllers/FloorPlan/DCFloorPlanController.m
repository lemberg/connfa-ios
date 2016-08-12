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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *floorButton;
@property (weak, nonatomic) IBOutlet UIButton *downArrowButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic)  UIImageView *imageView;
@property (strong, nonatomic) NSArray *floors;
@property (strong, nonatomic) NSArray *floorTitles;
@property (nonatomic) NSUInteger selectedActionIndex;
@property(nonatomic) __block DCMainProxyState previousState;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (weak, nonatomic) IBOutlet UIButton *showActionSheetButton;

@end

@implementation DCFloorPlanController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
  [self.scrollView addSubview:self.imageView];
  
  [self setZoomScale];
  [self setupGestureRecognizer];
  
  
  [self configureUI];
  [self setupGestureRecognizer];
  [self checkProxyState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerScreenLoadAtGA:[NSString stringWithFormat:@"%@", self.navigationItem.title]];
}

#pragma mark - Overrides

#pragma mark - Overrides

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  
  [self setZoomScale];
}

#pragma mark - Private

- (void)setZoomScale {
  CGSize imageViewSize = self.imageView.bounds.size;
  CGSize scrollViewSize = self.scrollView.bounds.size;
  CGFloat widthScale = scrollViewSize.width / imageViewSize.width;
  CGFloat heightScale = scrollViewSize.height / imageViewSize.height;
  
  self.scrollView.minimumZoomScale =  MIN(widthScale, heightScale);
  self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
  self.scrollView.maximumZoomScale = 1.0;
}

- (void)setContentInsets {
  CGSize imageViewSize = self.imageView.frame.size;
  CGSize scrollViewSize = self.scrollView.bounds.size;
  CGFloat verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0;
  CGFloat horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0;
  self.scrollView.contentInset = UIEdgeInsetsMake(verticalPadding, horizontalPadding, verticalPadding, horizontalPadding);
}

- (void)configureUI {
  self.headerView.backgroundColor = [DCAppConfiguration navigationBarColor];
  [self.floorButton setTitleColor:[DCAppConfiguration eventDetailNavBarTextColor] forState:UIControlStateNormal];
}

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
       }
     });
   }];
}

- (void)reloadData {
  NSMutableArray *floors = [NSMutableArray arrayWithArray:[[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCHousePlan class] inMainQueue:YES]];
  self.noDataView.hidden = floors.count > 0;
  self.showActionSheetButton.enabled = floors.count > 0;
  if (floors.count > 0) {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    [floors sortUsingDescriptors:@[sort]];
    self.floors = floors;
    
    NSMutableArray *floorTitles = [[NSMutableArray alloc] init];
    for (DCHousePlan *floorPlan in self.floors) {
      [floorTitles addObject:floorPlan.name];
    }
    self.floorTitles = [NSArray arrayWithArray:floorTitles];
    [self.floorButton setTitle:floorTitles[self.selectedActionIndex] forState:UIControlStateNormal];
    [self reloadImage];
    self.floorButton.enabled =  floors.count > 1 ? YES : NO;
    self.downArrowButton.hidden = floors.count > 1 ? NO : YES;
  } else {
    self.floorButton.hidden = YES;
    self.downArrowButton.hidden = YES;
  }
}

- (void)reloadImage {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  DCHousePlan *floorPlan = self.floors[self.selectedActionIndex];
  NSURL *URL = [NSURL URLWithString:floorPlan.imageURL];
  [self.imageView sd_setImageWithURL:URL placeholderImage:nil
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                             self.imageView.image = image;
                             CGRect frame = self.imageView.frame;
                             frame.size = image.size;
                             self.imageView.frame = frame;
                             self.scrollView.contentSize = image.size;
                             [self setZoomScale];
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

#pragma mark - Gesture Recognizer

- (void)setupGestureRecognizer {
  UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
  doubleTap.numberOfTapsRequired = 2;
  [self.scrollView addGestureRecognizer:doubleTap];
}

- (void)handleDoubleTap:(UITapGestureRecognizer*)recoginzer{
  if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
  }
  else{
    [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
  }
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

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
  [self setContentInsets];
}

@end
