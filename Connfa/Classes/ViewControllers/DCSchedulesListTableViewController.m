//
//  DCSchedulesListTableViewController.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 4/19/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCSchedulesListTableViewController.h"
#import "DCMainProxy+Additions.h"
#import "DCSharedSchedule+DC.h"

@interface DCSchedulesListTableViewController (){
  NSString *scheduleName;
  NSIndexPath *selectedIndexPath;
  EScheduleType selectedScheduleType;
    NSArray* schedules;
}

@end

@implementation DCSchedulesListTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupNavigationBar];
    schedules = [[DCMainProxy sharedProxy] getAllSharedSchedules];
}

-(void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
    [self selectCellForSelectedSchedule];
}

- (void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  [self setScheduleType];
  [_delegate setScheduleName:scheduleName];
  [_delegate setScheduleType:selectedScheduleType andSchedule:_selectedSchedule];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)selectCellForSelectedSchedule{
    int row = 0;
    if(_selectedSchedule){
        for (DCSharedSchedule* schedule in schedules) {
            if([schedule.scheduleId intValue] != [_selectedSchedule.scheduleId intValue]){
                row++;
            }
        }
    }
    selectedIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView selectRowAtIndexPath:selectedIndexPath animated:false scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:selectedIndexPath];
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
    int numberOfRows = 1;
    if(schedules){
        numberOfRows += schedules.count;
    }
  return numberOfRows;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.tintColor = [DCAppConfiguration navigationBarColor];
  
    if (indexPath.row == 0) {
        cell.textLabel.text = @"My Schedule";
    }else {
        DCSharedSchedule* sharedSchedule = [schedules objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = sharedSchedule.name;
    }
    
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
  UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
  cell.accessoryType = UITableViewCellAccessoryCheckmark;
  scheduleName = cell.textLabel.text;
  
  selectedIndexPath = indexPath;
    if(indexPath.row == 0){
        _selectedSchedule = nil;
    }else{
        _selectedSchedule = [schedules objectAtIndex:indexPath.row - 1];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}


@end
