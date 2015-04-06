//
//  DCEventDataSource.h
//  DrupalCon
//
//  Created by Olexandr on 4/6/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSArray+DC.h"
#import "DCEventStrategy.h"
#import "DCTimeRange+DC.h"
#import "DCTime.h"
#import "NSDate+DC.h"
#import "DCEvent+DC.h"

@import UIKit;

extern  NSString * kDCTimeslotKEY;
extern  NSString * kDCTimeslotEventKEY;

@class DCEventStrategy, DCEvent, DCTimeRange;
@protocol DCDayEventSourceProtocol;

@interface DCEventDataSource : NSObject<UITableViewDataSource, DCDayEventSourceProtocol>

@property (copy, nonatomic) UITableViewCell* (^prepareBlockForTableView)(UITableView *tableView, NSIndexPath *indexPath) ;


@property (strong, nonatomic) DCEventStrategy          *eventStrategy;
@property (strong, nonatomic) NSDate                   *selectedDay;
@property (strong, nonatomic)  NSArray          *eventsByTimeRange;

@property (weak, nonatomic  ) UITableView              *tableView;

- (instancetype)initWithTableView:(UITableView *)tableView
                    eventStrategy:(DCEventStrategy *)eventStrategy
                             date:(NSDate *)date;
- (void)updateActualEventIndexPathForTimeRange:(NSArray *)array;
- (NSArray *)eventsSortedByTimeRange:(NSArray *)events withUniqueTimeRange:(NSArray *)unqueTimeRange;

@end

@protocol DCDayEventSourceProtocol <NSObject>

- (void)reloadEvents;
- (DCEvent *)eventForIndexPath:(NSIndexPath *)indexPath;
- (DCTimeRange *)timeRangeForSection:(NSInteger)section;
- (NSIndexPath *)actualEventIndexPath;
- (NSString *)titleForSectionAtIdexPath:(NSInteger)section;

@end