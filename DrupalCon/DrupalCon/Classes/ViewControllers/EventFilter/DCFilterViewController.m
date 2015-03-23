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

@interface DCFilterViewController ()

@property (nonatomic, strong) NSArray* levels;
@property (nonatomic, strong) NSArray* tracks;

@property (nonatomic, strong) NSMutableArray* selectedLevels;
@property (nonatomic, strong) NSMutableArray* selectedTracks;

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
        
        self.selectedLevels = [NSMutableArray new];
        self.selectedTracks = [NSMutableArray new];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
        // this done to make Status bar white; status bar depends on Navigation bar style, because this VC is inside Navigation controller
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    NSPredicate * levelPredicate = [NSPredicate predicateWithFormat:@"NOT (levelId = 0)"];
    self.levels = [[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCLevel class] predicate:levelPredicate inMainQueue:YES];
    NSPredicate * trackPredicate = [NSPredicate predicateWithFormat:@"NOT (trackId = 0)"];
    self.tracks = [[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCTrack class] predicate:trackPredicate inMainQueue:YES];
    
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
        
        cell.checkBox.delegate = cell;
        cell.delegate = self;
        cell.type = cellType;
        cell.relatedObjectId = [self getCellId:cellType row:indexPath.row];
        cell.title.text = [self getCellTitle:cellType row:indexPath.row];
        cell.checkBox.selected = [self getCellSelected:cellType row:indexPath.row];
        cell.separator.hidden = [self isLastCellInSection: indexPath];
        
        return cell;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DCEventFilterCell* cell = (DCEventFilterCell*) [tableView dequeueReusableCellWithIdentifier:@"EventFilterCellIdentifier"];
    
    return cell.frame.size.height;
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - User actions handling

- (void) cellCheckBoxDidSelected:(BOOL)aSelected cellType:(FilterCellType)aType relatedObjectId:(NSNumber *)aId
{
    NSMutableArray* idArray = nil;
    
    switch (aType)
    {
        case FilterCellTypeLevel:
            idArray = self.selectedLevels;
            break;
            
        case FilterCellTypeTrack:
            idArray = self.selectedTracks;
            break;
            
        default:
            break;
    }
    
    NSAssert(idArray != nil, @"incorrect filter type");
    
    if (aSelected)
    {
        [idArray addObject:aId.stringValue];
    }
    else
    {
        [idArray removeObject:aId.stringValue];
    }
}

- (IBAction)onBackButtonClick:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) onClearButtonClick
{
    
}

- (IBAction)onDoneButtonClick:(id)sender
{
    if (self.delegate)
    {
        [self.delegate filterControllerWillDismissWithResult:self.selectedLevels.count ? self.selectedLevels : nil
                                                 tracks:self.selectedTracks.count ? self.selectedTracks : nil];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
