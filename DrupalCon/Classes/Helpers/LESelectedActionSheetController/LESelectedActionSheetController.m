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
  self.actionTitleColor = [UIColor blackColor];
  self.selectedActionTitleColor = [UIColor redColor];
  self.selectedItemIndex = 0;
  self.dismissTitle = @"Cancel";
  self.dismissTitleColor = [UIColor blackColor];
  self.dismissTintColor = [UIColor redColor];
  self.actionTitleFont = [UIFont systemFontOfSize:17.0];
  self.dismissTitleFont = [UIFont systemFontOfSize:17.0];
  self.requiredSelection = NO;
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
  self.tableView.scrollEnabled = NO;
  self.tableViewHeightConstraint.constant = self.itemHeight * [self.delegate numberOfActions];
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
  self.tableView.layer.cornerRadius = self.cornerRadius;
  self.tableView.clipsToBounds = YES;
  UIVisualEffectView *tableBackground = [[UIVisualEffectView alloc] initWithFrame: self.tableView.frame];
  tableBackground.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
  self.tableView.backgroundView = tableBackground;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  UIVisualEffectView *cellBackground = [[UIVisualEffectView alloc] initWithFrame:cell.frame];
  cellBackground.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
  cell.backgroundView = cellBackground;
  cell.backgroundView.alpha = 1.0;
  cell.backgroundColor = [UIColor clearColor];
  cell.textLabel.font = self.actionTitleFont;
  cell.textLabel.textAlignment = NSTextAlignmentCenter;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.tintColor = self.actionTitleColor;
  cell.textLabel.textColor = cell.tintColor;
  cell.textLabel.text = [self.delegate titleForActionAtIndex:indexPath.section];
  if (indexPath.section == self.selectedItemIndex)
    [self selectCell:cell];
}

- (void)selectCell:(UITableViewCell *)cell {
  cell.accessoryType = UITableViewCellAccessoryCheckmark;
  cell.tintColor = self.selectedActionTitleColor;
  cell.textLabel.textColor = cell.tintColor;
  cell.layoutMargins = UIEdgeInsetsMake(0, 45, 0, 0);
  cell.backgroundView.alpha = 0.4;
}

- (void)deselectCell:(UITableViewCell *)cell {
  cell.tintColor = self.actionTitleColor;
  cell.textLabel.textColor = cell.tintColor;
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
  cell.backgroundView.alpha = 1.0;
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
  view.backgroundColor = [UIColor clearColor];
  
  return view;
}

@end
