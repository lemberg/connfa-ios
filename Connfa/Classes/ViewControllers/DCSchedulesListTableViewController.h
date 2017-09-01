//
//  DCSchedulesListTableViewController.h
//  Connfa
//
//  Created by Oleh Kurnenkov on 4/19/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
  EMySchedule,
  EFriendSchedule
} EScheduleType;

@protocol ScheduleListDelegate
-(void)setScheduleName:(NSString *)name;
-(void)setScheduleType:(EScheduleType)scheduleType andSchedule:(DCSharedSchedule *)schedule;
@end

@interface DCSchedulesListTableViewController : UITableViewController
@property (nonatomic, weak) id <ScheduleListDelegate> delegate;
@property (nonatomic, strong)DCSharedSchedule* selectedSchedule;
@end
