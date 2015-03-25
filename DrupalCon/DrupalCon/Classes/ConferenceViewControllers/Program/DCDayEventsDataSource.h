//
//  DCDayEventsDataSource.h
//  DrupalCon
//
//  Created by Olexandr on 3/12/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

//typedef UITableViewCell* (^)(UITableView *tableView, NSIndexPath *indexPath);

@class DCEventStrategy, DCEvent, DCTimeRange;

@interface DCDayEventsDataSource : NSObject<UITableViewDataSource>

@property (copy, nonatomic) UITableViewCell* (^prepareBlockForTableView)(UITableView *tableView, NSIndexPath *indexPath) ;


- (instancetype)initWithTableView:(UITableView *)tableView
                    eventStrategy:(DCEventStrategy *)eventStrategy
                             date:(NSDate *)date;
- (void)reloadEvents;
- (DCEvent *)eventForIndexPath:(NSIndexPath *)indexPath;
- (DCTimeRange *)timeRangeForSection:(NSInteger)section;
- (NSIndexPath *)actualEventIndexPath;

@end
