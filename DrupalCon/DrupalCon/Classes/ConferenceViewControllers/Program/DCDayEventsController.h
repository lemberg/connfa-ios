//
//  DCDayEventsController.h
//  DrupalCon
//
//  Created by Olexandr on 3/10/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCBaseViewController.h"
#import "DCEventStrategy.h"
#import "DCProgramViewController.h"

@protocol DCUpdateDayEventProtocol;

@interface DCDayEventsController : DCBaseViewController <DCUpdateDayEventProtocol>

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDate *date;

//@property (nonatomic, strong) NSArray *timeslots;
//// timeslot element : dictionary "time slot value" : NSArray of events;

@property (nonatomic, weak) DCProgramViewController *parentProgramController;
@property (nonatomic, strong) DCEventStrategy * eventsStrategy;

- (void) initAsStubController:(NSString*)noEventMessage;
- (void) openDetailScreenForEvent:(DCEvent *)event;
- (void) updateEvents;

@end




@protocol DCUpdateDayEventProtocol <NSObject>

- (void)updateEvents;

@end