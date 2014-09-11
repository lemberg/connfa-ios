//
//  DCFavoritesViewController.m
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/4/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCFavoritesViewController.h"
#import "DCEventDetailViewController.h"
#import "AppDelegate.h"

#import "DCSpeechCell.h"
#import "DCSpeechOfDayCell.h"
#import "DCProgramHeaderCellView.h"

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

@interface DCFavoritesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *favoritesTableView;
@property (nonatomic, strong) DCFavoriteSourceManager *favoriteSourceMng;
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
    // Do any additional setup after loading the view.
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
    
    NSString *cellIdSpeech = @"ProgramCellIdentifierSpeech";
    NSString *cellIdSpeechOfDay = @"ProgramCellIdentifierSpeechOfDay";
    DCEvent * event = [self DC_eventForIndexPath:indexPath];
    UITableViewCell *cell;
    
    switch ([event getTypeID]) {
        case DC_EVENT_SPEACH: {
            DCSpeechCell *_cell = (DCSpeechCell*)[tableView dequeueReusableCellWithIdentifier: cellIdSpeech];
            [_cell setSpeakers:[self DC_speakersTextForSpeakerNames:[event speakersNames]]];
            [_cell setLevel:event.level.name];
            [_cell setTrack:[[event.tracks allObjects].firstObject name]];

            _cell.nameLabel.text = event.name;
            _cell.favoriteButton.selected = [event.favorite boolValue];
            [_cell favoriteButtonDidSelected:
             ^(UITableViewCell *cell, BOOL isSelected) {
                 [self updateFavoriteItemsInIndexPath:
                  [self.favoritesTableView indexPathForCell:cell]
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
            [_cell favoriteButtonDidSelected:
             ^(UITableViewCell *cell, BOOL isSelected) {
                 [self updateFavoriteItemsInIndexPath:
                  [self.favoritesTableView indexPathForCell:cell]
                                            withValue:isSelected];
             }];
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
    if (!isFavorite) {
        [[DCMainProxy sharedProxy]
         removeFavoriteEventWithID:event.eventID];
        [self deleteCellAtIndexPath:anIndexPath];
        
    }
    
}

- (void)deleteCellAtIndexPath:(NSIndexPath *)indexPath
{
    // If section has last event than remote them
    if ([self.favoriteSourceMng numberOfEventsInSection:indexPath.section] == 1) {
        
        [self.favoriteSourceMng deleteEventsAtIndexPath:indexPath];
        [self.favoriteSourceMng deleteSectionAtIndex:indexPath.section];
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
    
    DCTimeRange * timeslot = [self.favoriteSourceMng timeRangeForSection:section];//_timeslots[section];
    headerViewCell.startLabel.text = [timeslot.from stringValue];
    headerViewCell.endLabel.text = [timeslot.to stringValue];
    headerViewCell.dateLabel.text = [self.favoriteSourceMng dateForSection:section];
    // Hide time slot section when time is invalid
    [headerViewCell hideTimeSection:![timeslot.from isTimeValid]];
    return [headerViewCell contentView];
    
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
    return [self.favoriteSourceMng  numberOfEventsInSection:section];
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
    }
    return 94;
}

#pragma mark - uitableview delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __block DCEvent * event = [self DC_eventForIndexPath:indexPath];
    if([event getTypeID] == DC_EVENT_LUNCH || [event getTypeID] == DC_EVENT_COFEE_BREAK)
    {
        return;
    }
    
    DCEventDetailViewController * detailController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    [detailController setEvent:event];
    __block NSIndexPath *tmpIndex = indexPath;
    [detailController didCloseWithCallback:^{
        if (![event.favorite boolValue]) {
            [self deleteCellAtIndexPath:tmpIndex];
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

@end
