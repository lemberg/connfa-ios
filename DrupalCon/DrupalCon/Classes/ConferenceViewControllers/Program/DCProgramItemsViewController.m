//
//  DCProgramItemsViewController.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCProgramItemsViewController.h"
#import "DCEventDetailViewController.h"
#import "AppDelegate.h"

#import "DCSpeechCell.h"
#import "DCSpeechOfDayCell.h"
#import "DCCofeeCell.h"
#import "DCLunchCell.h"
#import "DCProgramHeaderCellView.h"

//#import "DCProgram+DC.h"
#import "DCEvent+DC.h"
#import "DCType+DC.h"
#import "DCTimeRange+DC.h"
#import "DCTime+DC.h"
#import "DCLevel+DC.h"
#import "DCTrack+DC.h"
#import "DCMainProxy+Additions.h"

#import "NSArray+DC.h"

@interface DCProgramItemsViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tablewView;

@end

@implementation DCProgramItemsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _events =  [self.eventsStrategy eventsForDayNum:self.pageIndex];
    _timeslots = [self.eventsStrategy uniqueTimeRangesForDayNum:self.pageIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - uitableview datasource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdSpeech = @"ProgramCellIdentifierSpeech";
    NSString *cellIdSpeechOfDay = @"ProgramCellIdentifierSpeechOfDay";
    NSString *cellIdCoffeBreak = @"ProgramCellIdentifierCoffeBreak";
    NSString *cellIdLunch = @"ProgramCellIdentifierLunch";
    
    DCEvent * event = [self DC_eventForIndexPath:indexPath];
    UITableViewCell *cell;
    
    switch ([event getTypeID]) {
        case DC_EVENT_SPEACH: {
            DCSpeechCell *_cell = (DCSpeechCell*)[tableView dequeueReusableCellWithIdentifier: cellIdSpeech];
            _cell.speakerLabel.text = [self DC_speakersTextForSpeakerNames:[event speakersNames]];
            _cell.experienceLevelLabel.text = event.level.name;
            _cell.trackLabel.text = [[event.tracks allObjects].firstObject name];
            _cell.nameLabel.text = event.name;
            _cell.favoriteButton.selected = [event.favorite boolValue];
            [_cell favoriteButtonDidSelected:^(UITableViewCell *cell, BOOL isSelected) {
                
                [self updateFavoriteItemsInIndexPath:[self.tablewView indexPathForCell:cell]
                                           withValue:isSelected];
            }];
            cell = _cell;
            break;
        }
        case DC_EVENT_SPEACH_OF_DAY: {
            DCSpeechOfDayCell *_cell = (DCSpeechOfDayCell*)[tableView dequeueReusableCellWithIdentifier: cellIdSpeechOfDay];
            _cell.speakerLabel.text = [self DC_speakersTextForSpeakerNames:[event speakersNames]];
            _cell.experienceLevelLabel.text = event.level.name;
            _cell.trackLabel.text = [[event.tracks allObjects].firstObject name];
            _cell.nameLabel.text = event.name;
            _cell.favoriteButton.selected = [event.favorite boolValue];
            [_cell favoriteButtonDidSelected:^(UITableViewCell *cell, BOOL isSelected) {
                [self updateFavoriteItemsInIndexPath:[self.tablewView indexPathForCell:cell]
                                           withValue:isSelected];
            }];
            cell = _cell;
            break;
        }
        case DC_EVENT_COFEE_BREAK: {
            DCCofeeCell *_cell = (DCCofeeCell*)[tableView dequeueReusableCellWithIdentifier: cellIdCoffeBreak];
            _cell.startLabel.text = [event.timeRange.from stringValue];
            _cell.endLabel.text = [event.timeRange.to stringValue];
            [_cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell = _cell;
            break;
        }
        case DC_EVENT_LUNCH: {
            DCLunchCell *_cell = (DCLunchCell*)[tableView dequeueReusableCellWithIdentifier: cellIdLunch];
            _cell.startLabel.text = [event.timeRange.from stringValue];
            _cell.endLabel.text = [event.timeRange.to stringValue];
            [_cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell = _cell;
            break;
        }
        default:
            break;
    }
    
    
    //Selection style
    /*
     UIView *selectedBackgroundView = [[UIView alloc] initWithFrame: cell.bounds];
     selectedBackgroundView.backgroundColor = [UIColor colorWithRed: 52./255. green: 52./255. blue: 59./255. alpha: 1.0];
     cell.selectedBackgroundView = selectedBackgroundView;
     */
    return cell;
}

- (void)updateFavoriteItemsInIndexPath:(NSIndexPath *)anIndexPath
                             withValue:(BOOL)isFavorite {
    DCEvent * event = [self DC_eventForIndexPath:anIndexPath];
    event.favorite = [NSNumber numberWithBool:isFavorite];
    if (isFavorite) {
        [[DCMainProxy sharedProxy]
         addToFavoriteEventWithID:event.eventID];
    } else {
        [[DCMainProxy sharedProxy]
         removeFavoriteEventWithID:event.eventID];
    }
    
    
}

-(BOOL) headerNeededInSection: (NSInteger) section
{
    /*lets check if this date range contains some events that need a time period header, DCSpeechCelll and DCSPeechofTheDayCell, if its only coffe breaks or lunch - we dont display a header*/
    BOOL headerNeeded = NO;
    for(DCEvent *event in [_events eventsForTimeRange:_timeslots[section]])
    {
        if([event getTypeID] == DC_EVENT_SPEACH || [event getTypeID] == DC_EVENT_SPEACH_OF_DAY)
        {
            headerNeeded = YES; break;
        }
    }
    return headerNeeded;
}


-(UIView*) tableView: (UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    DCProgramHeaderCellView *headerViewCell = (DCProgramHeaderCellView*)[tableView dequeueReusableCellWithIdentifier: @"ProgramCellHeaderCell"];
    //    lets check if this date range contains some events that need a time period header, DCSpeechCelll and DCSPeechofTheDayCell, if its only coffe breaks or lunch - we dont display a header
    BOOL headerNeeded = [self headerNeededInSection: section];
    if(headerNeeded) {
        DCTimeRange * timeslot = _timeslots[section];
        headerViewCell.startLabel.text = [timeslot.from stringValue];
        headerViewCell.endLabel.text = [timeslot.to stringValue];
        return headerViewCell;
    }
    UIView *v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 0.0)];
    v.backgroundColor = [UIColor whiteColor];
    return v;
}

-(CGFloat) tableView: (UITableView*) tableView heightForHeaderInSection:(NSInteger)section {
    BOOL headerNeeded = [self headerNeededInSection: section];
    return headerNeeded ? 97 : 1.0;
}

-(CGFloat)  tableView: (UITableView*) tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}

- (NSString*) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _timeslots.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_events eventsForTimeRange:(DCTimeRange*)_timeslots[section]].count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCEvent *event = [self DC_eventForIndexPath:indexPath];
    
    switch ([event getTypeID]) {
        case DC_EVENT_SPEACH: {
            return 97;
            break;
        }
        case DC_EVENT_SPEACH_OF_DAY: {
            return 97;
            break;
        }
        case DC_EVENT_COFEE_BREAK: {
            return 94;
            break;
        }
        case DC_EVENT_LUNCH: {
            return 94;
            break;
        }
    }
    return 94;
}

#pragma mark - uitableview delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DCEvent * event = [self DC_eventForIndexPath:indexPath];
    if([event getTypeID] == DC_EVENT_LUNCH || [event getTypeID] == DC_EVENT_COFEE_BREAK)
    {
        return;
    }
    
    DCEventDetailViewController * detailController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    [detailController didCloseWithCallback:^{
        [self.tablewView reloadData];
    }];
    [detailController setEvent:event];
    UINavigationController * navContainer = [[UINavigationController alloc] initWithRootViewController:detailController];
    [navContainer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:navContainer animated:YES completion:nil];
}

#pragma mark - private

- (DCEvent*)DC_eventForIndexPath:(NSIndexPath *)indexPath
{
    return [[_events eventsForTimeRange:_timeslots[indexPath.section]] objectAtIndex:indexPath.row];
}

- (NSString*)DC_speakersTextForSpeakerNames:(NSArray*)speakerNames
{
    NSString * resultStr = @"";
    if (speakerNames.count == 1)
    {
        resultStr = speakerNames[0];
    }
    else if (speakerNames.count == 2)
    {
        resultStr = [NSString stringWithFormat:@"%@\n%@",speakerNames[0], speakerNames[1]];
    }
    else if (speakerNames.count > 2)
    {
        resultStr = [NSString stringWithFormat:@"%@\n...",speakerNames[0]];
    }
    return resultStr;
}

@end
