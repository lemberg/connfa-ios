//
//  LESelectedActionSheetController.m
//  LESelectedActionSheetExample
//
//  Created by Serhii Bocharnikov on 6/9/16.
//  Copyright © 2016 Serhii Bocharnikov. All rights reserved.
//

#import "LESelectedActionSheetController.h"

static NSString * const cellIdentifier = @"cellIdenifier";

@interface LESelectedActionSheetController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewBoottomConstraint;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *cancelView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (strong, nonatomic) UIView *shadowView;
@property (nonatomic) NSInteger maxNumberOfItems;

@end

@implementation LESelectedActionSheetController

#pragma mark - Lifecycle

- (instancetype)init {
  self = [super init];
  if (self) {
    [self defaultInit];
  }
  
  return self;
}

- (void)defaultInit {
  self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
  self.cornerRadius = 12.0;
  self.itemHeight = 58.0;
  self.actionTextColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
  self.actionTitleColor = [DCAppConfiguration favoriteEventColor];
  self.selectedActionTitleColor = [DCAppConfiguration favoriteEventColor];
  self.selectedItemIndex = 0;
  self.dismissTitle = @"Cancel";
  self.dismissTitleColor = [DCAppConfiguration favoriteEventColor];
  self.dismissTintColor = [DCAppConfiguration favoriteEventColor];
  self.actionTitleFont = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold];
  self.dismissTitleFont = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold];
  self.requiredSelection = NO;
  self.maxNumberOfItems = [UIScreen mainScreen].bounds.size.height == 480 ? 6 : 8;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self.presentingViewController.view addSubview:self.shadowView];
  [self configureTableView];
  [self configureCancelView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [UIView animateWithDuration:0.3 animations:^{
    self.shadowView.alpha = 1.0;
  }];
}

#pragma mark - IBActions

- (IBAction)cancel:(id)sender {
  [self dismiss];
}

#pragma mark - Public


#pragma mark - Private

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (UIView *)shadowView {
  if (!_shadowView) {
    _shadowView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
    _shadowView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
    _shadowView.alpha = 0.0;
  }
  
  return _shadowView;
}

- (void)dismiss {
  double delayInSeconds = 0.1;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self dismissViewControllerAnimated:YES completion:^{
      [self.shadowView removeFromSuperview];
    }];
  });
}

- (void)configureCancelView {
  self.cancelButtonHeightConstraint.constant = self.requiredSelection ? 0.0: self.itemHeight;
  self.cancelViewBoottomConstraint.constant = self.requiredSelection ? 0.0: 5.0;
  self.cancelView.layer.cornerRadius = self.cornerRadius;
  self.cancelView.clipsToBounds = YES;
  [self.dismissButton setTitleColor:self.dismissTitleColor forState:UIControlStateNormal];
  [self.dismissButton setTitleColor:self.dismissTintColor forState:UIControlStateHighlighted];
  [self.dismissButton setTitle:self.dismissTitle forState:UIControlStateNormal];
  self.dismissButton.titleLabel.font = self.dismissTitleFont;
}

- (void)configureTableView {
  [self configureTableViewHeight];
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
  self.tableView.layer.cornerRadius = self.cornerRadius;
  self.tableView.clipsToBounds = YES;
  UIView *tableBackground = [[UIView alloc] initWithFrame: self.tableView.frame];
  tableBackground.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
  self.tableView.backgroundView = tableBackground;
}

- (void)configureTableViewHeight {
  NSInteger numberOfItems = [self.delegate numberOfActions];
  if (numberOfItems <= self.maxNumberOfItems) {
    self.tableView.scrollEnabled = NO;
    self.tableViewHeightConstraint.constant = self.itemHeight * numberOfItems + numberOfItems - 1;
  } else {
    self.tableView.scrollEnabled = YES;
    self.tableViewHeightConstraint.constant = self.itemHeight * self.maxNumberOfItems + self.maxNumberOfItems - 1;
  }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  cell.backgroundView.alpha = 1.0;
  cell.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
  cell.textLabel.font = self.actionTitleFont;
  cell.textLabel.textAlignment = NSTextAlignmentLeft;
  cell.selectionStyle = UITableViewCellSelectionStyleGray;
  cell.layoutMargins = UIEdgeInsetsMake(0, 16, 0, 0);
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.tintColor = self.actionTitleColor;
  cell.textLabel.textColor = self.actionTextColor;
  cell.textLabel.text = [self.delegate titleForActionAtIndex:indexPath.section];
  if (indexPath.section == self.selectedItemIndex)
    [self selectCell:cell];
}

- (void)selectCell:(UITableViewCell *)cell {
  cell.accessoryType = UITableViewCellAccessoryCheckmark;
  cell.tintColor = self.selectedActionTitleColor;
  cell.textLabel.textColor = self.selectedActionTitleColor;
  cell.layoutMargins = UIEdgeInsetsMake(0, 16, 0, 0);
}

- (void)deselectCell:(UITableViewCell *)cell {
  cell.tintColor = self.actionTitleColor;
  cell.textLabel.textColor = cell.tintColor;
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.layoutMargins = UIEdgeInsetsMake(0, 16, 0, 0);
}

#pragma mark - Overrides

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
  [super dismissViewControllerAnimated:animated completion:completion];
  
  [UIView animateWithDuration:0.2 animations:^{
    self.shadowView.alpha = 0.0;
  }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [self.delegate numberOfActions];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  [self configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.selectedItemIndex != indexPath.section) {
    [self selectCell:[tableView cellForRowAtIndexPath:indexPath]];
    [self deselectCell:[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.selectedItemIndex]]];
    self.selectedItemIndex = indexPath.section;
  }
  [self.delegate performActionAtIndex:indexPath.section];
  [self dismiss];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return self.itemHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 1)];
  view.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:222.0/255.0 alpha:1.0];
  
  return view;
}

@end
