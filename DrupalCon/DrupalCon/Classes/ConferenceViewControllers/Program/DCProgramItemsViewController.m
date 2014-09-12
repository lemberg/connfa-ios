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

static NSString * kDCTimeslotKEY = @"timeslot_key";
static NSString * kDCTimeslotEventKEY = @"timeslot_event_key";

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
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray * events_ = [self.eventsStrategy eventsForDayNum:self.pageIndex];
        NSMutableArray * timeslots_ = [[NSMutableArray alloc] initWithCapacity:events_.count];
        NSArray * uniqueTimeranges_ = [self.eventsStrategy uniqueTimeRangesForDayNum:self.pageIndex];
        for (DCTimeRange * timerange_ in uniqueTimeranges_)
        {
            NSArray * timeslotEvents_ = [events_ eventsForTimeRange:timerange_];
            NSDictionary * timeslotDict = [[NSDictionary alloc] initWithObjects:@[timerange_, timeslotEvents_] forKeys:@[kDCTimeslotKEY, kDCTimeslotEventKEY]];
            [timeslots_ addObject:timeslotDict];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"s");
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            strongSelf.timeslots = timeslots_;
            NSLog(@".");
            [strongSelf.tablewView reloadData];
            NSLog(@"f");
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - uitableview datasource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell s");
    NSString *cellIdSpeech = @"ProgramCellIdentifierSpeech";
    NSString *cellIdSpeechOfDay = @"ProgramCellIdentifierSpeechOfDay";
    NSString *cellIdCoffeBreak = @"ProgramCellIdentifierCoffeBreak";
    NSString *cellIdLunch = @"ProgramCellIdentifierLunch";
    DCEvent * event = [self DC_eventForIndexPath:indexPath];
    UITableViewCell *cell;
    
    switch ([event getTypeID]) {
        case DC_EVENT_NONE:
        {
            NSLog(@"WRONG! there is no Type for event: %@",event);
        }
        case DC_EVENT_24h:
        case DC_EVENT_GROUP:
        case DC_EVENT_SPEACH: {
            DCSpeechCell *_cell = (DCSpeechCell*)[tableView dequeueReusableCellWithIdentifier: cellIdSpeech];
            [_cell setSpeakers:[self DC_speakersTextForSpeakerNames:[event speakersNames]]];
            [_cell setLevel:event.level.name];
            [_cell setTrack:[[event.tracks allObjects].firstObject name]];
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
            [_cell setSpeakers:[self DC_speakersTextForSpeakerNames:[event speakersNames]]];
            [_cell setLevel:event.level.name];
            [_cell setTrack:[[event.tracks allObjects].firstObject name]];

            _cell.nameLabel.text = event.name;
            _cell.favoriteButton.selected = [event.favorite boolValue];
            [_cell favoriteButtonDidSelected:^(UITableViewCell *cell, BOOL isSelected) {
                [self updateFavoriteItemsInIndexPath:[self.tablewView indexPathForCell:cell]
                                           withValue:isSelected];
            }];
            cell = _cell;
            break;
        }
        case DC_EVENT_WALKING:
        {
            DCCofeeCell *_cell = (DCCofeeCell*)[tableView dequeueReusableCellWithIdentifier: cellIdCoffeBreak];
            [_cell.leftImageView setImage:[UIImage imageNamed:@"program_walking_break"]];
            _cell.startLabel.text = [event.timeRange.from stringValue];
            _cell.endLabel.text = [event.timeRange.to stringValue];
            [_cell setSelectionStyle:UITableViewCellSelectionStyleNone];
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
    
        NSLog(@"cell f");
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
    for(DCEvent *event in [_timeslots[section] objectForKey:kDCTimeslotEventKEY])
    {
        if([event getTypeID] != DC_EVENT_LUNCH && [event getTypeID] != DC_EVENT_COFEE_BREAK && [event getTypeID] != DC_EVENT_WALKING)
        {
            headerNeeded = YES; break;
        }
    }
    return headerNeeded;
}

-(UIView*) tableView: (UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSLog(@"view s");
    DCProgramHeaderCellView *headerViewCell = (DCProgramHeaderCellView*)[tableView dequeueReusableCellWithIdentifier: @"ProgramCellHeaderCell"];
    //    lets check if this date range contains some events that need a time period header, DCSpeechCelll and DCSPeechofTheDayCell, if its only coffe breaks or lunch - we dont display a header
    BOOL headerNeeded = [self headerNeededInSection: section];
    if(headerNeeded) {
        DCTimeRange * timeslot = [_timeslots[section] objectForKey:kDCTimeslotKEY];
        [headerViewCell.leftImageView setImage:[[[_timeslots[section] objectForKey:kDCTimeslotEventKEY] firstObject] imageForEvent]];
        headerViewCell.startLabel.text = [timeslot.from stringValue];
        headerViewCell.endLabel.text = [timeslot.to stringValue];
        // Hide time slot section when time is invalid
        [headerViewCell hideTimeSection:![timeslot.from isTimeValid]];
        return headerViewCell;
    }
    UIView *v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 0.0)];
    v.backgroundColor = [UIColor whiteColor];
    NSLog(@"view f");
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
    NSLog(@"sect");
    return _timeslots.count;
        NSLog(@"sect f");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        NSLog(@"rows");
    return [[_timeslots[section] objectForKey:kDCTimeslotEventKEY] count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCEvent *event = [self DC_eventForIndexPath:indexPath];
    
    switch ([event getTypeID]) {
        case DC_EVENT_24h:
        case DC_EVENT_GROUP:
        case DC_EVENT_WALKING:
        case DC_EVENT_SPEACH:
        case DC_EVENT_SPEACH_OF_DAY: {
            return 97;
            break;
        }
        case DC_EVENT_COFEE_BREAK:
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

    if(![self headerNeededInSection:indexPath.section])
        return;
    
    DCEvent * event = [self DC_eventForIndexPath:indexPath];

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
    return [[_timeslots[indexPath.section] objectForKey:kDCTimeslotEventKEY] objectAtIndex:indexPath.row];
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
