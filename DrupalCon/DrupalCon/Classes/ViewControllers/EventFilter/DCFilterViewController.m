//
//  DCFilterViewController.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 2/23/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCFilterViewController.h"
#import "DCLevel.h"
#import "DCTrack.h"
#import "DCMainProxy.h"
#import "DCEventFilterHeaderCell.h"
#import "NSManagedObject+DC.h"
#import "DCCoreDataStore.h"

@interface DCFilterViewController ()

@property (nonatomic, strong) NSArray* levels;
@property (nonatomic, strong) NSArray* tracks;
@property (nonatomic) BOOL isFilterCleared;

@property (nonatomic, strong) IBOutlet UIBarButtonItem* cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* doneButton;

@end

@implementation DCFilterViewController

#pragma mark - View lifecykle

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
        // this done to make Status bar white; status bar depends on Navigation bar style, because this VC is inside Navigation controller
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [self updateSourceData];
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
        // show buttons just now to avoid "jump" affect
    [self.navigationItem setLeftBarButtonItem:self.cancelButton animated:YES];
    [self.navigationItem setRightBarButtonItem:self.doneButton animated:YES];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
        // this method is called when NavController is dismissed; status bar of previous controller will be white
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private

- (void) updateSourceData
{
    NSPredicate * levelPredicate = [NSPredicate predicateWithFormat:@"NOT (levelId = 0)"];
    self.levels = [[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCLevel class] predicate:levelPredicate inMainQueue:YES];
    NSSortDescriptor *levelSort = [NSSortDescriptor sortDescriptorWithKey:@"levelId" ascending:YES];
    self.levels = [self.levels sortedArrayUsingDescriptors:@[levelSort]];
    
    NSPredicate * trackPredicate = [NSPredicate predicateWithFormat:@"NOT (trackId = 0)"];
    self.tracks = [[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCTrack class] predicate:trackPredicate inMainQueue:YES];
    NSSortDescriptor *trackSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    self.tracks = [self.tracks sortedArrayUsingDescriptors:@[trackSort]];
    
    self.isFilterCleared = ([self allItemsAreSelected:YES array:self.levels] && [self allItemsAreSelected:YES array:self.tracks]);
    
    NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    [[DCCoreDataStore  mainQueueContext] setUndoManager:undoManager];
    [undoManager beginUndoGrouping];
}

- (void) setAllItemsSelected: (BOOL) selected
{
    [self.levels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(DCLevel*)obj setSelectedInFilter: [NSNumber numberWithBool:selected]];
    }];
    
    [self.tracks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(DCTrack*)obj setSelectedInFilter: [NSNumber numberWithBool:selected]];
    }];
}

- (BOOL) allItemsAreSelected:(BOOL)selected array:(NSArray*)array
{
    for (NSObject *item in array)
    {
        if (![(NSNumber*)[item valueForKey:@"selectedInFilter"] boolValue] == selected)
            return NO;
    }
    
    return YES;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return FilterCellTypeCount;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    FilterCellType type = [self getCellType:section];
    
    switch (type)
    {
        case FilterCellTypeLevel:
            return self.levels.count;
            
        case FilterCellTypeTrack:
            return self.tracks.count;
        
        case FilterCellTypeButton:
            return 1;
        default:
            NSAssert(false, @"unhanled Filter type");
    }
    
    return 0;
}

- (NSString*) getHeaderTitle:(FilterCellType)cellType
{
    NSString* headerTitle = nil;
    
    switch (cellType)
    {
        case FilterCellTypeLevel:
            headerTitle = @"Experience";
            break;
            
        case FilterCellTypeTrack:
            headerTitle = @"Track";
            break;
        
        case FilterCellTypeButton:
            headerTitle = @"";
            break;
    }
    
    NSAssert(headerTitle != nil, @"no header title");
    
    return headerTitle;
}

- (FilterCellType) getCellType:(NSInteger)section
{
    return (int)section;
}

- (NSString*) getCellTitle:(FilterCellType)aCellType row:(NSInteger)aRow
{
    NSString* cellTitle = nil;
    
    switch (aCellType)
    {
        case FilterCellTypeLevel:
            cellTitle = [(DCLevel*)[self.levels objectAtIndex: aRow] name];
            break;
            
        case FilterCellTypeTrack:
            cellTitle = [(DCTrack*)[self.tracks objectAtIndex: aRow] name];
            break;
            
        default:
            break;
    }
    
    NSAssert(cellTitle != nil, @"no cell title");
    
    return cellTitle;
}

- (BOOL) getCellSelected:(FilterCellType)aCellType row:(NSInteger)aRow
{
    switch (aCellType)
    {
        case FilterCellTypeLevel:
            return [(DCLevel*)[self.levels objectAtIndex: aRow] selectedInFilter].boolValue;
            
        case FilterCellTypeTrack:
            return [(DCTrack*)[self.tracks objectAtIndex: aRow] selectedInFilter].boolValue;
            
        default:
            return NO;
    }
}

- (NSNumber*) getCellId:(FilterCellType)aCellType row:(NSInteger)aRow
{
    NSNumber* cellId = nil;
    
    switch (aCellType)
    {
        case FilterCellTypeLevel:
            cellId = [(DCLevel*)[self.levels objectAtIndex: aRow] levelId];
            break;
            
        case FilterCellTypeTrack:
            cellId = [(DCTrack*)[self.tracks objectAtIndex: aRow] trackId];
            break;
        
        default:
            break;
    }
    
    NSAssert(cellId != nil, @"no cell id");
    
    return cellId;
}

- (BOOL) isLastCellInSection:(NSIndexPath*)aPath
{
    FilterCellType type = [self getCellType: aPath.section];
    
    switch (type)
    {
        case FilterCellTypeLevel:
            return ((aPath.row+1) == self.levels.count);
            
        case FilterCellTypeTrack:
            return ((aPath.row+1) == self.tracks.count);
            
        default:
            NSAssert(false, @"unhandled Filter type");
    }
    
    return NO;
}

#pragma mark - UITabelViewDataSource delegate

-(UIView*) tableView: (UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DCEventFilterHeaderCell* headerCell = (DCEventFilterHeaderCell*) [tableView dequeueReusableCellWithIdentifier:@"EventFilterHeaderCellIdentifier"];
    
    headerCell.title.text = [self getHeaderTitle: [self getCellType:section]];
    
    return headerCell.contentView;
}

-(UIView*) tableView: (UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UITableViewCell* footerCell = (UITableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"EventFilterFooterIdentifier"];
    return footerCell.contentView;
}

-(CGFloat) tableView: (UITableView*) tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
}

-(CGFloat)  tableView: (UITableView*) tableView heightForFooterInSection:(NSInteger)section
{
    return (section == FilterCellTypeButton) ? 44.0f : 1.0f;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FilterCellType cellType = [self getCellType:indexPath.section];
    
    if (cellType == FilterCellTypeButton)
    {
        return [tableView dequeueReusableCellWithIdentifier:@"EventFilterButtonIdentifier"];
    }
    else
    {
        DCEventFilterCell* cell = (DCEventFilterCell*) [tableView dequeueReusableCellWithIdentifier:@"EventFilterCellIdentifier"];
        
        cell.type = cellType;
        cell.relatedObjectId = [self getCellId:cellType row:indexPath.row];
        cell.title.text = [self getCellTitle:cellType row:indexPath.row];
        cell.checkBox.selected = self.isFilterCleared ? NO : [self getCellSelected:cellType row:indexPath.row];
        cell.checkBox.userInteractionEnabled = NO;
        cell.separator.hidden = [self isLastCellInSection: indexPath];
        
        return cell;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DCEventFilterCell* cell = (DCEventFilterCell*) [tableView dequeueReusableCellWithIdentifier:@"EventFilterCellIdentifier"];
    
    return cell.frame.size.height;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isFilterCleared)
    {
        [self setAllItemsSelected: NO];
        self.isFilterCleared = NO;
    }
    
    switch (indexPath.section)
    {
        case FilterCellTypeButton:
        {
            [self onClearButtonClick];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
            return;
            
        case FilterCellTypeLevel:
        {
            DCLevel* level = [self.levels objectAtIndex:indexPath.row];
            level.selectedInFilter = [NSNumber numberWithBool: !level.selectedInFilter.boolValue];
//            [[DCCoreDataStore  mainQueueContext] save:nil];
        }
            break;
        case FilterCellTypeTrack:
        {
            DCLevel* track = [self.tracks objectAtIndex:indexPath.row];
            track.selectedInFilter = [NSNumber numberWithBool: !track.selectedInFilter.boolValue];
//            [[DCCoreDataStore  mainQueueContext] save:nil];
        }
            break;
    }
    DCEventFilterCell* cell = (DCEventFilterCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.checkBox.selected = !cell.checkBox.selected;
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - User actions handling

- (IBAction)onBackButtonClick:(id)sender
{
    NSUndoManager* manager = [[DCCoreDataStore  mainQueueContext] undoManager];
    [manager endUndoGrouping];
    [manager undo];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) onClearButtonClick
{
    [self setAllItemsSelected: YES];
    self.isFilterCleared = YES;
    
    [self.tableView reloadData];
}

- (IBAction)onDoneButtonClick:(id)sender
{

        // when all items are deselected, select all
    if ([self allItemsAreSelected:NO array:self.levels] &&
        [self allItemsAreSelected:NO array:self.tracks])
    {
        [self setAllItemsSelected:YES];
    }
    
    NSUndoManager* manager = [[DCCoreDataStore  mainQueueContext] undoManager];
    [manager endUndoGrouping];

    [[DCCoreDataStore  defaultStore] saveMainContextWithCompletionBlock:^(BOOL isSuccess) {
        if (self.delegate)
        {
            [self.delegate filterControllerWillDismiss];
            
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];

    }];
    

    
}

@end
