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

#import "DCFavoritesViewController.h"
#import "DCEventDetailViewController.h"
#import "AppDelegate.h"

#import "DCSpeechCell.h"
#import "DCSpeechOfDayCell.h"
#import "DCProgramHeaderCellView.h"
#import "DCEventBaseCell.h"

#import "DCProgram+DC.h"
#import "DCEvent+DC.h"
#import "DCType+DC.h"
#import "DCTimeRange+DC.h"
#import "DCTime+DC.h"
#import "DCLevel+DC.h"
#import "DCTrack+DC.h"
#import "DCMainProxy+Additions.h"

#import "NSArray+DC.h"
#import "DCFavoriteSourceManager.h"
#import "DCBof.h"

@interface DCFavoritesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *favoritesTableView;
@property (weak, nonatomic) IBOutlet UIImageView *noDataImg;
@property (nonatomic, strong) DCFavoriteSourceManager *favoriteSourceMng;
@property (nonatomic, strong) DCEvent *openEvent;
@end

@implementation DCFavoritesViewController

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
    self.favoriteSourceMng = [[DCFavoriteSourceManager alloc]
                            initWithSection:[[DCMainProxy sharedProxy] favoriteEvents]];
    [self registerCellsInTableView];
    if (self.openEvent) {
        [self openEvent:self.openEvent];
        self.openEvent = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self DC_checkEmptyness];
}

static NSString *const cellIdSpeech = @"ProgramCellIdentifierSpeech";
static NSString *const cellIdSpeechOfDay = @"ProgramCellIdentifierSpeechOfDay";

- (void)registerCellsInTableView
{
    [self.favoritesTableView registerClass:[DCSpeechCell class]
            forCellReuseIdentifier:cellIdSpeech];
    [self.favoritesTableView registerClass:[DCSpeechOfDayCell class]
            forCellReuseIdentifier:cellIdSpeechOfDay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - uitableview datasource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSString *cellIdSpeech = @"ProgramCellIdentifierSpeech";
//    NSString *cellIdSpeechOfDay = @"ProgramCellIdentifierSpeechOfDay";
    DCEvent * event = [self DC_eventForIndexPath:indexPath];
    UITableViewCell *cell;
    
    switch ([event getTypeID]) {
        case DC_EVENT_NONE:
        case DC_EVENT_24h:
        case DC_EVENT_GROUP:
        case DC_EVENT_WALKING:
        case DC_EVENT_REGISTRATION:
        case DC_EVENT_SPEACH: {
            DCSpeechCell *_cell = (DCSpeechCell*)[tableView dequeueReusableCellWithIdentifier: cellIdSpeech];
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
        default:
            break;
    }
    
    return cell;
}

- (BOOL)isEventDetailEmpty:(DCEvent *)event
{
    NSString *speakers = [self DC_speakersTextForSpeakerNames:[event speakersNames]];
    NSString *level = event.level.name;
    NSString *track = [[event.tracks allObjects].firstObject name];
    if ([event isMemberOfClass:[DCBof class]]) return ![event.place length];
    return ![level length] && ![speakers length] && ![track length];
}

- (void)updateCell:(DCEventBaseCell *)cell witEvent:(DCEvent *)event
{
    NSString *speakers = [self DC_speakersTextForSpeakerNames:[event speakersNames]];
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
        
        [self updateFavoriteItemsInIndexPath:[self.favoritesTableView indexPathForCell:cell]
                                   withValue:isSelected];
    }];
    
}

- (void)updateFavoriteItemsInIndexPath:(NSIndexPath *)anIndexPath
                             withValue:(BOOL)isFavorite {
    DCEvent * event = [self DC_eventForIndexPath:anIndexPath];
    event.favorite = [NSNumber numberWithBool:isFavorite];
    if (!isFavorite) {
        [[DCMainProxy sharedProxy]
         removeFavoriteEventWithID:event.eventID];
        [self deleteCellAtIndexPath:anIndexPath];
    }
    [self DC_checkEmptyness];
}

- (void)deleteCellAtIndexPath:(NSIndexPath *)indexPath
{
    // If section has last event than remote them
    if ([self.favoriteSourceMng numberOfEventsInSection:(int)indexPath.section] == 1) {
        
        [self.favoriteSourceMng deleteEventsAtIndexPath:indexPath];
        [self.favoriteSourceMng deleteSectionAtIndex:(int)indexPath.section];
        [self.favoritesTableView beginUpdates];
        [self.favoritesTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                               withRowAnimation:UITableViewRowAnimationFade];
        [self.favoritesTableView endUpdates];
    } else {
        // Remove event
        [self.favoriteSourceMng deleteEventsAtIndexPath:indexPath];
        [self.favoritesTableView beginUpdates];
        [self.favoritesTableView deleteRowsAtIndexPaths:@[indexPath]
                                       withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.favoritesTableView endUpdates];
    }
    
}


-(UIView*) tableView: (UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    DCProgramHeaderCellView *headerViewCell = (DCProgramHeaderCellView*)[tableView dequeueReusableCellWithIdentifier: @"ProgramCellHeaderCell"];
    
    DCTimeRange * timeslot = [self.favoriteSourceMng timeRangeForSection:(int)section];
    [headerViewCell.leftImageView setImage:[[self DC_eventForIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]] imageForEvent]];
    headerViewCell.startLabel.text = [timeslot.from stringValue];
    headerViewCell.endLabel.text = [timeslot.to stringValue];
    headerViewCell.dateLabel.text = [self.favoriteSourceMng dateForSection:(int)section];
    // Hide time slot section when time is invalid
    [headerViewCell hideTimeSection:![timeslot.from isTimeValid]];
    [self removeGesturesFromView:headerViewCell.contentView];
    return [headerViewCell contentView];
    
}

- (void)removeGesturesFromView:(UIView *)view
{
    while (view.gestureRecognizers.count) {
        [view removeGestureRecognizer:[view.gestureRecognizers objectAtIndex:0]];
    }
    
}


-(CGFloat) tableView: (UITableView*) tableView heightForHeaderInSection:(NSInteger)section {
    return  97;
}

-(CGFloat)  tableView: (UITableView*) tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}

- (NSString*) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.favoriteSourceMng numberOfSection];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.favoriteSourceMng  numberOfEventsInSection:(int)section];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCEvent *event = [self DC_eventForIndexPath:indexPath];
    return ([self isEventDetailEmpty:event])? 60 : 97;

}

#pragma mark - uitableview delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __block DCEvent * event = [self DC_eventForIndexPath:indexPath];

    [self openEvent:event withIndexPath:indexPath];
}

- (void)openEvent:(DCEvent *)newEvent
{
    [self openEvent:newEvent withIndexPath:nil];
}

- (void)openEvent:(DCEvent *)newEvent withIndexPath:(NSIndexPath *)indexPath
{
    __block DCEvent * event = newEvent;
    
    DCEventDetailViewController * detailController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    [detailController setEvent:event];
    __block NSIndexPath *tmpIndex = indexPath;
    [detailController didCloseWithCallback:^{
        if (![event.favorite boolValue]) {
            if (tmpIndex) {
                [self deleteCellAtIndexPath:tmpIndex];
            } else {
                [self.favoritesTableView reloadData];
            }
            
        }
        
    }];
    UINavigationController * navContainer = [[UINavigationController alloc] initWithRootViewController:detailController];
    [navContainer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:navContainer animated:YES completion:nil];
}

#pragma mark - private

- (DCEvent*)DC_eventForIndexPath:(NSIndexPath *)indexPath
{
    return [self.favoriteSourceMng eventForIndexPath:indexPath];
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

- (void)DC_checkEmptyness
{
    BOOL isEmpty = ([self.favoriteSourceMng numberOfSection] == 0);
    _favoritesTableView.hidden = isEmpty;
    _noDataImg.hidden = !isEmpty;
}

@end
