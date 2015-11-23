
#import "DCEventDataSource.h"
#import "NSCalendar+DC.h"

@interface DCEventDataSource ()

@property(strong, nonatomic) NSIndexPath* actualEventIndexPath;


@end

@implementation DCEventDataSource

- (instancetype)initWithTableView:(UITableView*)tableView
                    eventStrategy:(DCEventStrategy*)eventStrategy
                             date:(NSDate*)date {
  self = [super init];
  if (self) {
    self.tableView = tableView;
    self.tableView.dataSource = self;
    self.eventStrategy = eventStrategy;
    self.selectedDay = date;
    self.actualEventIndexPath = nil;
    [self loadEvents];
  }
  return self;
}

/**
 *  This method should be reload in child classes it responsibles to load events 
 *  according to DCEventStrategy
 */
- (void)loadEvents {
  // TODO: Reload in the child classes
}

- (void)reloadEvents {
  [self loadEvents];
}

const NSString* kDCTimeslotKEY = @"timeslot_key";
const NSString* kDCTimeslotEventKEY = @"timeslot_event_key";

- (NSArray*)eventsSortedByTimeRange:(NSArray*)events
                withUniqueTimeRange:(NSArray*)unqueTimeRange {
  NSMutableArray* uniqueTimeSlotsSource = [NSMutableArray array];

  NSArray* eventsForDay = events;
  NSArray* uniqueTimeSlotForDay = unqueTimeRange;

  for (DCTimeRange* timerange in uniqueTimeSlotForDay) {
    NSArray* timeslotEvents =
        [[[eventsForDay eventsForTimeRange:timerange] sortedByKey:kDCEventIdKey]
            sortedByKey:kDCEventOrderKey];

    NSDictionary* timeslotDict = [[NSDictionary alloc]
        initWithObjects:@[ timerange, timeslotEvents ]
                forKeys:@[ kDCTimeslotKEY, kDCTimeslotEventKEY ]];
    [uniqueTimeSlotsSource addObject:timeslotDict];
  }

  return [NSArray arrayWithArray:uniqueTimeSlotsSource];
}

#pragma mark - TableViewDataSource implementation

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  NSParameterAssert(self.prepareBlockForTableView);
  return self.prepareBlockForTableView(tableView, indexPath);
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
  return self.eventsByTimeRange.count;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section {
  return [self.eventsByTimeRange[section][kDCTimeslotEventKEY] count];
}

- (DCEvent*)eventForIndexPath:(NSIndexPath*)indexPath {
  return self
      .eventsByTimeRange[indexPath.section][kDCTimeslotEventKEY][indexPath.row];
}

- (DCTimeRange*)timeRangeForSection:(NSInteger)section {
  return self.eventsByTimeRange[section][kDCTimeslotKEY];
}

- (NSString*)titleForSectionAtIdexPath:(NSInteger)section {
  //    TODO: Reload in the child classes
  return nil;
}

- (void)updateActualEventIndexPathForTimeRange:(NSArray*)array {
  float currentHour = [NSDate currentHour];
  NSInteger sectionNumber = 0;

  if (![NSDate dc_isDateInToday:self.selectedDay]) {
    self.actualEventIndexPath = nil;
    return;
  }

  for (NSDictionary* sectionInfo in array) {
    DCTimeRange* timeRange = sectionInfo[kDCTimeslotKEY];

    float from = [NSDate hoursFromDate:timeRange.from];
    float to = [NSDate hoursFromDate:timeRange.to];

    // if Current hour is before Current time range, return Current time range
    if (currentHour < from) {
      self.actualEventIndexPath =
          [NSIndexPath indexPathForItem:0 inSection:sectionNumber];
      return;
    }

    // if Current hour is in time range, return this time range
    if (from <= currentHour && currentHour <= to) {
      self.actualEventIndexPath =
          [NSIndexPath indexPathForItem:0 inSection:sectionNumber];
      return;
    }

    sectionNumber++;
  }

  // set the last Range
  self.actualEventIndexPath =
      [NSIndexPath indexPathForItem:0
                          inSection:sectionNumber > 0 ? sectionNumber - 1 : 0];
}

- (NSIndexPath*)actualEventIndexPath {
  return _actualEventIndexPath;
}

- (void)dataSourceStartUpdateEvents {
  if ([self.delegate
          respondsToSelector:@selector(dataSourceStartUpdateEvents:)]) {
    [self.delegate dataSourceStartUpdateEvents:self];
  }
}

- (void)dataSourceEndUpdateEvents {
  if ([self.delegate
          respondsToSelector:@selector(dataSourceEndUpdateEvents:)]) {
    [self.delegate dataSourceEndUpdateEvents:self];
  }
}

@end
