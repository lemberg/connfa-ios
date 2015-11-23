
#import <Foundation/Foundation.h>
#import "NSArray+DC.h"
#import "DCEventStrategy.h"
#import "DCTimeRange+DC.h"
#import "DCTime.h"
#import "NSDate+DC.h"
#import "DCEvent+DC.h"

@import UIKit;

extern NSString* kDCTimeslotKEY;
extern NSString* kDCTimeslotEventKEY;

@class DCEventStrategy, DCEvent, DCTimeRange, DCEventDataSource;

@protocol DCDayEventSourceDelegate<NSObject>

- (void)dataSourceStartUpdateEvents:(DCEventDataSource*)dataSource;
- (void)dataSourceEndUpdateEvents:(DCEventDataSource*)dataSource;

@end

@protocol DCDayEventSourceProtocol<NSObject>

- (void)reloadEvents;
- (DCEvent*)eventForIndexPath:(NSIndexPath*)indexPath;
- (DCTimeRange*)timeRangeForSection:(NSInteger)section;
- (NSIndexPath*)actualEventIndexPath;
- (NSString*)titleForSectionAtIdexPath:(NSInteger)section;

@end


/**
 *  @class DCEventDataSource is the base data source for all days events,
 */

@interface DCEventDataSource
    : NSObject<UITableViewDataSource, DCDayEventSourceProtocol>

@property(copy, nonatomic) UITableViewCell* (^prepareBlockForTableView)
    (UITableView* tableView, NSIndexPath* indexPath);

@property(strong, nonatomic) DCEventStrategy* eventStrategy;
@property(strong, nonatomic) NSDate* selectedDay;
@property(strong, nonatomic) NSArray* eventsByTimeRange;

@property(weak, nonatomic) UITableView* tableView;

@property(weak, nonatomic) id<DCDayEventSourceDelegate> delegate;

- (instancetype)initWithTableView:(UITableView*)tableView
                    eventStrategy:(DCEventStrategy*)eventStrategy
                             date:(NSDate*)date;
- (void)updateActualEventIndexPathForTimeRange:(NSArray*)array;
- (NSArray*)eventsSortedByTimeRange:(NSArray*)events
                withUniqueTimeRange:(NSArray*)unqueTimeRange;
// Callbacks for update delegate methods
- (void)dataSourceStartUpdateEvents;
- (void)dataSourceEndUpdateEvents;
@end
