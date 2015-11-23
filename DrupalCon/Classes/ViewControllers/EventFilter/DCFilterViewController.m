
#import "DCFilterViewController.h"
#import "DCLevel.h"
#import "DCTrack.h"
#import "DCMainProxy.h"
#import "DCEventFilterHeaderCell.h"
#import "NSManagedObject+DC.h"
#import "DCCoreDataStore.h"

@interface DCFilterViewController ()

@property(nonatomic, weak) IBOutlet UITableView* tableView;

@property(nonatomic, strong) NSArray* levelsToShow;
@property(nonatomic, strong) NSArray* levelsAll;
@property(nonatomic, strong) NSArray* tracksToShow;
@property(nonatomic, strong) NSArray* tracksAll;

@property(nonatomic) BOOL isLevelFilterCleared;
@property(nonatomic) BOOL isTrackFilterCleared;

@property(nonatomic, strong) IBOutlet UIBarButtonItem* cancelButton;
@property(nonatomic, strong) IBOutlet UIBarButtonItem* doneButton;

@end

@implementation DCFilterViewController

#pragma mark - View lifecykle

- (instancetype)initWithCoder:(NSCoder*)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // this done to make Status bar white; status bar depends on Navigation bar
  // style, because this VC is inside Navigation controller
  self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;

  [self updateSourceData];
  [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // show buttons just now to avoid "jump" affect
  [self.navigationItem setLeftBarButtonItem:self.cancelButton animated:YES];
  [self.navigationItem setRightBarButtonItem:self.doneButton animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  // this method is called when NavController is dismissed; status bar of
  // previous controller will be white
  return UIStatusBarStyleLightContent;
}

#pragma mark - Private

- (void)updateSourceData {
  self.levelsAll =
      [[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCLevel class]
                                              predicate:nil
                                            inMainQueue:YES];
  NSSortDescriptor* levelSort =
      [NSSortDescriptor sortDescriptorWithKey:@"levelId" ascending:YES];
  self.levelsAll = [self.levelsAll sortedArrayUsingDescriptors:@[ levelSort ]];

  NSPredicate* whichLevelsWillBeShown =
      [NSPredicate predicateWithFormat:@"NOT (levelId = 0)"];
  self.levelsToShow =
      [self.levelsAll filteredArrayUsingPredicate:whichLevelsWillBeShown];

  self.tracksAll =
      [[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCTrack class]
                                              predicate:nil
                                            inMainQueue:YES];
  NSSortDescriptor* trackSort =
      [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
  self.tracksAll = [self.tracksAll sortedArrayUsingDescriptors:@[ trackSort ]];

  NSPredicate* whichTracksWillBeShown =
      [NSPredicate predicateWithFormat:@"NOT (trackId = 0)"];
  self.tracksToShow =
      [self.tracksAll filteredArrayUsingPredicate:whichTracksWillBeShown];

  self.isLevelFilterCleared =
      [self allItemsAreSelected:YES array:self.levelsToShow];
  self.isTrackFilterCleared =
      [self allItemsAreSelected:YES array:self.tracksToShow];

  NSUndoManager* undoManager = [[NSUndoManager alloc] init];
  [[DCCoreDataStore mainQueueContext] setUndoManager:undoManager];
  [undoManager beginUndoGrouping];
}

- (void)setAllItemsSelected:(BOOL)selected array:(NSArray*)array {
  [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
    [obj setValue:[NSNumber numberWithBool:selected]
           forKey:@"selectedInFilter"];
  }];
}

- (BOOL)allItemsAreSelected:(BOOL)selected array:(NSArray*)array {
  for (NSObject* item in array) {
    if (![(NSNumber*)[item valueForKey:@"selectedInFilter"] boolValue] ==
        selected)
      return NO;
  }

  return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
  return FilterCellTypeCount;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section {
  FilterCellType type = [self getCellType:section];

  switch (type) {
    case FilterCellTypeLevel:
      return self.levelsToShow.count;

    case FilterCellTypeTrack:
      return self.tracksToShow.count;

    default:
      NSAssert(false, @"unhanled Filter type");
  }

  return 0;
}

- (NSString*)getHeaderTitle:(FilterCellType)cellType {
  NSString* headerTitle = nil;

  switch (cellType) {
    case FilterCellTypeLevel:
      headerTitle = @"Experience Levels";
      break;

    case FilterCellTypeTrack:
      headerTitle = @"Tracks";
      break;
  }

  NSAssert(headerTitle != nil, @"no header title");

  return headerTitle;
}

- (FilterCellType)getCellType:(NSInteger)section {
  return (int)section;
}

- (NSString*)getCellTitle:(FilterCellType)aCellType row:(NSInteger)aRow {
  NSString* cellTitle = nil;

  switch (aCellType) {
    case FilterCellTypeLevel:
      cellTitle = [(DCLevel*)[self.levelsToShow objectAtIndex:aRow] name];
      break;

    case FilterCellTypeTrack:
      cellTitle = [(DCTrack*)[self.tracksToShow objectAtIndex:aRow] name];
      break;

    default:
      break;
  }

  NSAssert(cellTitle != nil, @"no cell title");

  return cellTitle;
}

- (BOOL)getCellSelected:(FilterCellType)aCellType row:(NSInteger)aRow {
  switch (aCellType) {
    case FilterCellTypeLevel:
      return [(DCLevel*)[self.levelsToShow objectAtIndex:aRow] selectedInFilter]
          .boolValue;

    case FilterCellTypeTrack:
      return [(DCTrack*)[self.tracksToShow objectAtIndex:aRow] selectedInFilter]
          .boolValue;

    default:
      return NO;
  }
}

- (NSNumber*)getCellId:(FilterCellType)aCellType row:(NSInteger)aRow {
  NSNumber* cellId = nil;

  switch (aCellType) {
    case FilterCellTypeLevel:
      cellId = [(DCLevel*)[self.levelsToShow objectAtIndex:aRow] levelId];
      break;

    case FilterCellTypeTrack:
      cellId = [(DCTrack*)[self.tracksToShow objectAtIndex:aRow] trackId];
      break;

    default:
      break;
  }

  NSAssert(cellId != nil, @"no cell id");

  return cellId;
}

- (BOOL)isLastCellInSection:(NSIndexPath*)aPath {
  FilterCellType type = [self getCellType:aPath.section];

  switch (type) {
    case FilterCellTypeLevel:
      return ((aPath.row + 1) == self.levelsToShow.count);

    case FilterCellTypeTrack:
      return ((aPath.row + 1) == self.tracksToShow.count);

    default:
      NSAssert(false, @"unhandled Filter type");
  }

  return NO;
}

#pragma mark - UITabelViewDataSource delegate

- (UIView*)tableView:(UITableView*)tableView
    viewForHeaderInSection:(NSInteger)section {
  DCEventFilterHeaderCell* headerCell = (DCEventFilterHeaderCell*)[tableView
      dequeueReusableCellWithIdentifier:@"EventFilterHeaderCellIdentifier"];

  headerCell.title.text = [self getHeaderTitle:[self getCellType:section]];

  return headerCell.contentView;
}

- (UIView*)tableView:(UITableView*)tableView
    viewForFooterInSection:(NSInteger)section {
  UITableViewCell* footerCell = (UITableViewCell*)[tableView
      dequeueReusableCellWithIdentifier:@"EventFilterFooterIdentifier"];
  return footerCell.contentView;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForHeaderInSection:(NSInteger)section {
  return 44.0f;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForFooterInSection:(NSInteger)section {
  return 1.0f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  FilterCellType cellType = [self getCellType:indexPath.section];

  DCEventFilterCell* cell = (DCEventFilterCell*)[tableView
      dequeueReusableCellWithIdentifier:@"EventFilterCellIdentifier"];

  cell.type = cellType;
  cell.relatedObjectId = [self getCellId:cellType row:indexPath.row];
  cell.title.text = [self getCellTitle:cellType row:indexPath.row];

  BOOL properFilterCleared = (cellType == FilterCellTypeLevel)
                                 ? self.isLevelFilterCleared
                                 : self.isTrackFilterCleared;
  cell.checkBox.selected =
      properFilterCleared ? NO
                          : [self getCellSelected:cellType row:indexPath.row];
  cell.checkBox.userInteractionEnabled = NO;
  cell.separator.hidden = [self isLastCellInSection:indexPath];

  return cell;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  DCEventFilterCell* cell = (DCEventFilterCell*)[tableView
      dequeueReusableCellWithIdentifier:@"EventFilterCellIdentifier"];

  return cell.frame.size.height;
}

- (void)tableView:(UITableView*)tableView
    didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  switch (indexPath.section) {
    case FilterCellTypeLevel: {
      if (self.isLevelFilterCleared) {
        [self setAllItemsSelected:NO array:self.levelsAll];
        self.isLevelFilterCleared = NO;
      }
      DCLevel* level = [self.levelsToShow objectAtIndex:indexPath.row];
      level.selectedInFilter =
          [NSNumber numberWithBool:!level.selectedInFilter.boolValue];
    } break;
    case FilterCellTypeTrack: {
      if (self.isTrackFilterCleared) {
        [self setAllItemsSelected:NO array:self.tracksAll];
        self.isTrackFilterCleared = NO;
      }

      DCLevel* track = [self.tracksToShow objectAtIndex:indexPath.row];
      track.selectedInFilter =
          [NSNumber numberWithBool:!track.selectedInFilter.boolValue];
    } break;
  }
  DCEventFilterCell* cell = (DCEventFilterCell*)
      [self tableView:tableView cellForRowAtIndexPath:indexPath];
  cell.checkBox.selected = !cell.checkBox.selected;

  [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - User actions handling

- (IBAction)onBackButtonClick:(id)sender {
  NSUndoManager* manager = [[DCCoreDataStore mainQueueContext] undoManager];
  [manager endUndoGrouping];
  [manager undo];

  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClearButtonClick {
  [self setAllItemsSelected:YES array:self.levelsAll];
  [self setAllItemsSelected:YES array:self.tracksAll];

  self.isLevelFilterCleared = YES;
  self.isTrackFilterCleared = YES;

  [self.tableView reloadData];
}

- (IBAction)onDoneButtonClick:(id)sender {
  // when all items in Section are deselected, select all
  if ([self allItemsAreSelected:NO array:self.levelsToShow] ||
      [self allItemsAreSelected:YES array:self.levelsToShow]) {
    [self setAllItemsSelected:YES array:self.levelsAll];
  }

  if ([self allItemsAreSelected:NO array:self.tracksToShow] ||
      [self allItemsAreSelected:YES array:self.tracksToShow]) {
    [self setAllItemsSelected:YES array:self.tracksAll];
  }

  NSUndoManager* manager = [[DCCoreDataStore mainQueueContext] undoManager];
  [manager endUndoGrouping];

  [[DCCoreDataStore defaultStore]
      saveMainContextWithCompletionBlock:^(BOOL isSuccess) {
        if (self.delegate) {
          [self.delegate filterControllerWillDismiss:NO];
        }

        [self.navigationController dismissViewControllerAnimated:YES
                                                      completion:nil];
      }];
}

- (void)printData {
  NSLog(@"\n");
  for (DCLevel* level in self.levelsToShow)
    NSLog(@"level: %@, selected: %@\n", level.name, level.selectedInFilter);
  for (DCTrack* track in self.tracksToShow)
    NSLog(@"track: %@, selected: %@\n", track.name, track.selectedInFilter);

  NSLog(@"level cleared: %d, tracks cleared: %d\n", self.isLevelFilterCleared,
        self.isTrackFilterCleared);
}

@end
