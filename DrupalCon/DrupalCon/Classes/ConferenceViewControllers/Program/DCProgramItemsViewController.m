//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
#import "DCLabel.h"
#import "DCEventBaseCell.h"
#import "DCLimitedNavigationController.h"
#import "DCAppFacade.h"

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

static NSString * kDCTimeslotKEY = @"timeslot_key";
static NSString * kDCTimeslotEventKEY = @"timeslot_event_key";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray * events_ = [self.eventsStrategy eventsForDay:self.date];
        NSMutableArray * timeslots_ = [[NSMutableArray alloc] initWithCapacity:events_.count];
        NSArray * uniqueTimeranges_ = [self.eventsStrategy uniqueTimeRangesForDay:self.date];
        for (DCTimeRange * timerange_ in uniqueTimeranges_)
        {
            NSArray * timeslotEvents_ = [events_ eventsForTimeRange:timerange_];
            NSDictionary * timeslotDict = [[NSDictionary alloc] initWithObjects:@[timerange_, timeslotEvents_] forKeys:@[kDCTimeslotKEY, kDCTimeslotEventKEY]];
            [timeslots_ addObject:timeslotDict];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            strongSelf.timeslots = timeslots_;
            [strongSelf.tablewView reloadData];
        });
    });
    [self registerCellsInTableView];
}

static NSString *const cellIdSpeech = @"ProgramCellIdentifierSpeech";
static NSString *const cellIdSpeechOfDay = @"ProgramCellIdentifierSpeechOfDay";

- (void)registerCellsInTableView
{
    [self.tablewView registerClass:[DCSpeechCell class]
            forCellReuseIdentifier:cellIdSpeech];
    [self.tablewView registerClass:[DCSpeechOfDayCell class]
            forCellReuseIdentifier:cellIdSpeechOfDay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - uitableview datasource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdCoffeBreak = @"ProgramCellIdentifierCoffeBreak";
    NSString *cellIdLunch = @"ProgramCellIdentifierLunch";
    DCEvent * event = [self eventForIndexPath:indexPath];
    UITableViewCell *cell;
    
    switch ([event getTypeID]) {
        case DC_EVENT_NONE:
        {
            NSLog(@"WRONG! there is no Type for event: %@",event);
        }
        
        case DC_EVENT_24h:
        case DC_EVENT_SPEACH: {
            DCSpeechCell *_cell = (DCSpeechCell *)[tableView dequeueReusableCellWithIdentifier: cellIdSpeech];
            [self updateCell:_cell witEvent:event];
            cell = _cell;
            break;
        }
        case DC_EVENT_SPEACH_OF_DAY: {
            DCSpeechOfDayCell *_cell = (DCSpeechOfDayCell*)[tableView dequeueReusableCellWithIdentifier: cellIdSpeechOfDay];
            [self updateCell:_cell witEvent:event];
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
        case DC_EVENT_REGISTRATION:
        {
            DCCofeeCell *_cell = (DCCofeeCell*)[tableView dequeueReusableCellWithIdentifier: cellIdCoffeBreak];
            [_cell.leftImageView setImage:[UIImage imageNamed:@"program_check_in"]];
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
        
        case DC_EVENT_GROUP:
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
    return cell;
}

- (BOOL)isEventDetailEmpty:(DCEvent *)event
{
    NSString *speakers = [self speakersTextForSpeakerNames:[event speakersNames]];
    NSString *level = event.level.name;
    NSString *track = [[event.tracks allObjects].firstObject name];
    if ([event isMemberOfClass:[DCBof class]]) return ![event.place length];
    return ![level length] && ![speakers length] && ![track length];
}

- (void)updateCell:(DCEventBaseCell *)cell witEvent:(DCEvent *)event
{
    NSString *speakers = [self speakersTextForSpeakerNames:[event speakersNames]];
    NSString *level = event.level.name;
    NSString *track = [[event.tracks allObjects].firstObject name];
    NSString *title = event.name;
    NSDictionary *values = nil;
    BOOL displayEmptyDetailInfo = [self isEventDetailEmpty:event];
    
    if ([event isMemberOfClass:[DCBof class]]) {
        values = @{
                   kHeaderTitle:title,
                   kLeftBlockTitle: ([event.place length])?@"Place":@"",
                   kLeftBlockContent:event.place
                   };
    } else if (![level length] && ![speakers length] && [track length]) {
        values = @{
                   kHeaderTitle:title,
                   kLeftBlockTitle: @"Track",
                   kLeftBlockContent:track
                   };
    } else if (displayEmptyDetailInfo) {
        values = @{
                   kHeaderTitle:title,
                   };
    } else {
        values = @{
                   kHeaderTitle: title,
                   kLeftBlockTitle: ([speakers length])?@"Speakers":@"",
                   kLeftBlockContent: speakers,
                   kMiddleBlockTitle: ([track length])?@"Track":@"",
                   kMiddleBlockContent: track,
                   kRightBlockTitle: ([level length])?@"Experience Level":@"",
                   kRightBlockContent: level
                   };
        
        
    }
    
    
    
    [cell setValuesForCell: values];
    cell.favoriteButton.selected = [event.favorite boolValue];
    [cell favoriteButtonDidSelected:^(UITableViewCell *cell, BOOL isSelected) {
        
        [self updateFavoriteItemsInIndexPath:[self.tablewView indexPathForCell:cell]
                                   withValue:isSelected];
    }];
    
}


- (void)updateFavoriteItemsInIndexPath:(NSIndexPath *)anIndexPath
                             withValue:(BOOL)isFavorite {
    
    DCEvent * event = [self eventForIndexPath:anIndexPath];
    event.favorite = [NSNumber numberWithBool:isFavorite];
    if (isFavorite) {
        [[DCMainProxy sharedProxy] addToFavoriteEvent:event];
    } else {
        [[DCMainProxy sharedProxy] removeFavoriteEventWithID:event.eventId];
    }
}

-(BOOL) headerNeededInSection: (NSInteger) section
{
    /*lets check if this date range contains some events that need a time period header, DCSpeechCelll and DCSPeechofTheDayCell, if its only coffe breaks or lunch - we dont display a header*/
    BOOL headerNeeded = NO;
    for(DCEvent *event in [_timeslots[section] objectForKey:kDCTimeslotEventKEY])
    {
        if([event getTypeID] != DC_EVENT_LUNCH &&
           [event getTypeID] != DC_EVENT_COFEE_BREAK &&
           [event getTypeID] != DC_EVENT_WALKING &&
           [event getTypeID] != DC_EVENT_REGISTRATION)
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
        DCTimeRange * timeslot = [_timeslots[section] objectForKey:kDCTimeslotKEY];
        [headerViewCell.leftImageView setImage:[[[_timeslots[section] objectForKey:kDCTimeslotEventKEY] firstObject] imageForEvent]];
        headerViewCell.startLabel.text = [timeslot.from stringValue];
        headerViewCell.endLabel.text = [timeslot.to stringValue];
        // Hide time slot section when time is invalid
        [headerViewCell hideTimeSection:![timeslot.from isTimeValid]];
        [self removeGesturesFromView:headerViewCell.contentView];
        return [headerViewCell contentView];
    }
    UIView *v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 0.0)];
    v.backgroundColor = [UIColor whiteColor];
    return v;
}

- (void)removeGesturesFromView:(UIView *)view
{
    while (view.gestureRecognizers.count) {
        [view removeGestureRecognizer:[view.gestureRecognizers objectAtIndex:0]];
    }

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
    return [[_timeslots[section] objectForKey:kDCTimeslotEventKEY] count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCEvent *event = [self eventForIndexPath:indexPath];
    
    switch ([event getTypeID]) {
        case DC_EVENT_24h:
        case DC_EVENT_WALKING:
            return 97;
            break;
        
        case DC_EVENT_SPEACH:
        case DC_EVENT_SPEACH_OF_DAY: {
            return ([self isEventDetailEmpty:event])? 60 : 97;
            break;
        }
        case DC_EVENT_REGISTRATION:
        case DC_EVENT_GROUP:
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
    

    
}

- (BOOL)isClickEnableForEvent:(DCEvent *)event
{
    NSInteger type = [event getTypeID];
    return !(type != DC_EVENT_GROUP &&
            type != DC_EVENT_REGISTRATION &&
            type != DC_EVENT_LUNCH);
}

#pragma mark - private

- (DCEvent*)eventForIndexPath:(NSIndexPath *)indexPath
{
    return [[_timeslots[indexPath.section] objectForKey:kDCTimeslotEventKEY] objectAtIndex:indexPath.row];
}

- (NSString*)speakersTextForSpeakerNames:(NSArray*)speakerNames
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
