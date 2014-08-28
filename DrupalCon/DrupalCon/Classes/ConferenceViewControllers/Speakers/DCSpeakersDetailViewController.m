//
//  DCSpeakersDetailViewController.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/27/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCSpeakersDetailViewController.h"
#import "NSDate+DC.h"

#import "DCSpeaker+DC.h"
#import "DCEvent+DC.h"
#import "DCTimeRange+DC.h"
#import "DCTrack+DC.h"
#import "DCLevel+DC.h"

#import "DCDescriptionTextCell.h"
#import "DCSpeakerHeaderCell.h"
#import "DCSpeakerEventCell.h"

@interface DCSpeakersDetailViewController ()

@property (nonatomic, strong) NSArray * events;
@property (nonatomic, weak) IBOutlet UITableView * speakerDetailTbl;

@end

@implementation DCSpeakersDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigatorBarStyle = EBaseViewControllerNatigatorBarStyleTransparrent;
    _events = [_speaker.events allObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.navigationController)
    {
        self.navigatorBarStyle = EBaseViewControllerNatigatorBarStyleNormal;
        [super viewWillAppear:animated];
        self.title = @"Speaker Profile";
    }
    else
    {
        UIButton* backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [backButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
        [backButton setFrame:CGRectMake(0, 0, 60, 64)];
        [backButton setExclusiveTouch:YES];
        [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [backButton setTitle:@"Back" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.view addSubview:backButton];
        
        UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
        [titleLbl setTextAlignment:NSTextAlignmentCenter];
        [titleLbl setTextColor:[UIColor whiteColor]];
        [titleLbl setText:@"Profile"];
        [titleLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:21]];
        [self.view addSubview:titleLbl];
        
        [_speakerDetailTbl setFrame:CGRectMake(0, 44, 320, self.view.bounds.size.height-44)];
    }    
}

-(void)onBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView Delegate/DataSourse methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _events.count + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return [DCSpeakerHeaderCell cellHeight];
    
    else if ([self isLastRow:indexPath.row])
        return [DCDescriptionTextCell cellHeightForText:_speaker.characteristic];
    
    else
        return [DCSpeakerEventCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdEvent = @"cellId_SpeakersEvent";
    static NSString *cellIdHeader = @"cellId_SpeakersHeader";
    static NSString *cellIdBottom = @"cellId_SpeakersBottom";
    
    UITableViewCell *cell;
    
    if (indexPath.row == 0)
    {
        DCSpeakerHeaderCell *_cell = (DCSpeakerHeaderCell*)[tableView dequeueReusableCellWithIdentifier:cellIdHeader];
        [_cell.pictureImg setImage:[UIImage imageNamed:@"avatar_test_image"]];
        [_cell.nameLbl setText:_speaker.name];
        [_cell.organizationLbl setText:_speaker.organizationName];
        [_cell.jobTitleLbl setText:_speaker.jobTitle];
        cell = _cell;
    }
    
    else if ([self isLastRow:indexPath.row])
    {
        DCDescriptionTextCell * _cell = (DCDescriptionTextCell*)[tableView dequeueReusableCellWithIdentifier:cellIdBottom];
        [_cell.descriptionTxt setText:_speaker.characteristic];
        cell = _cell;
    }
    
    else // all events cells
    {
        DCEvent * event = _events[indexPath.row-1];
        DCSpeakerEventCell * _cell = (DCSpeakerEventCell*)[tableView dequeueReusableCellWithIdentifier:cellIdEvent];
        _cell.favorite = NO;
        [_cell.eventNameValueLbl setText:event.name];
        [_cell.eventDateValueLbl setText:[event.date stringForSpeakerEventCell]];
        [_cell.eventTimeValueLbl setText:[event.timeRange stringValue]];
        [_cell.eventTrackValueLbl setText:[[event.tracks allObjects].firstObject name]];
        [_cell.eventLevelValueLbl setText:event.level.name];
        cell = _cell;
    }

    return cell;
}

#pragma mark - 

- (BOOL)isLastRow:(NSInteger)row
{
    return (row == _events.count + 1);
}

@end
