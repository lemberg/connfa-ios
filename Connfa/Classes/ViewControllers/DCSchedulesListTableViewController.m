//
//  DCSchedulesListTableViewController.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 4/19/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCSchedulesListTableViewController.h"

@interface DCSchedulesListTableViewController (){
  NSString *scheduleName;
  NSIndexPath *selectedIndexPath;
  EScheduleType selectedScheduleType;
}

@end

@implementation DCSchedulesListTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupNavigationBar];
}

-(void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  [self.tableView selectRowAtIndexPath:selectedIndexPath animated:false scrollPosition:UITableViewScrollPositionNone];
  [self tableView:self.tableView didSelectRowAtIndexPath:selectedIndexPath];
}

- (void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  [self setScheduleType];
  [_delegate setScheduleName:scheduleName];
  [_delegate setScheduleType:selectedScheduleType];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)setupNavigationBar{
  UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeController)];
  self.navigationItem.leftBarButtonItem = closeButton;
  self.navigationController.navigationBar.barTintColor =
  [DCAppConfiguration navigationBarColor];
}

-(void)closeController{
  [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

-(void)setScheduleType {
  if (selectedIndexPath.row == 0) {
    selectedScheduleType = EMySchedule;
  }else {
    selectedScheduleType = EFriendSchedule;
  }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
  cell.textLabel.text = [NSString stringWithFormat:@"Schedule %ld", (long)indexPath.row];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.tintColor = [DCAppConfiguration navigationBarColor];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
  UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
  cell.accessoryType = UITableViewCellAccessoryCheckmark;
  scheduleName = cell.textLabel.text;
  
  selectedIndexPath = indexPath;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}


@end
