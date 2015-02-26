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
    
    self.levels = [[DCMainProxy sharedProxy] levelInstances];
    self.tracks = [[DCMainProxy sharedProxy] trackInstances];
    
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
        // show buttons just now to avoid "jump" affect
    [self.navigationItem setLeftBarButtonItem:self.cancelButton animated:YES];
    [self.navigationItem setRightBarButtonItem:self.doneButton animated:YES];
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
    return 1.0f;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DCEventFilterCell* cell = (DCEventFilterCell*) [tableView dequeueReusableCellWithIdentifier:@"EventFilterCellIdentifier"];
    
    FilterCellType cellType = [self getCellType:indexPath.section];
    
    cell.checkBox.selected = NO;
    cell.checkBox.delegate = cell;
    cell.delegate = self;
    cell.type = cellType;
    cell.relatedObjectId = [self getCellId:cellType row:indexPath.row];
    cell.title.text = [self getCellTitle:cellType row:indexPath.row];
    cell.separator.hidden = [self isLastCellInSection: indexPath];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DCEventFilterCell* cell = (DCEventFilterCell*) [tableView dequeueReusableCellWithIdentifier:@"EventFilterCellIdentifier"];
    
    return cell.frame.size.height;
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
    }
    
    NSAssert(idArray != nil, @"incorrect filter type");
    
    if (aSelected)
    {
        [idArray addObject:aId];
    }
    else
    {
        [idArray removeObject:aId];
    }
}

- (IBAction)onBackButtonClick:(id)sender
{
    if ([self.presentingViewController conformsToProtocol:@protocol(DCFilterViewControllerDelegate)])
    {
        id delegate = self.presentingViewController;
        [delegate filterControllerWillDismissWithResult:nil tracks:nil];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onDoneButtonClick:(id)sender
{
    if ([self.presentingViewController conformsToProtocol:@protocol(DCFilterViewControllerDelegate)])
    {
        id delegate = self.presentingViewController;
        [delegate filterControllerWillDismissWithResult:self.selectedLevels.count ? self.selectedLevels : nil
                                                 tracks:self.selectedTracks.count ? self.selectedTracks : nil];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
