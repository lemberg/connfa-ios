//
//  DCDayEventsController.h
//  DrupalCon
//
//  Created by Olexandr on 3/10/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCBaseViewController.h"
#import "DCEventStrategy.h"

@protocol DCUpdateDayEventProtocol;

@interface DCDayEventsController : DCBaseViewController<DCUpdateDayEventProtocol>

@property (nonatomic, strong) NSDate *date;

//@property (nonatomic, strong) NSArray *timeslots;
//// timeslot element : dictionary "time slot value" : NSArray of events;

@property (nonatomic, strong) DCEventStrategy * eventsStrategy;

- (void) initAsStubController:(NSString*)noEventMessage;

@end




@protocol DCUpdateDayEventProtocol <NSObject>

- (void)updateEvents;

@end