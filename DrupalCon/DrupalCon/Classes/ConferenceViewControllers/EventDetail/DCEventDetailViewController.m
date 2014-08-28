//
//  DCEventDetailViewController.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/26/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCEventDetailViewController.h"
#import "DCSpeakersDetailViewController.h"

#import "DCEvent+DC.h"
#import "DCProgram+DC.h"
#import "DCTimeRange+DC.h"
#import "DCSpeaker+DC.h"
#import "DCLevel+DC.h"
#import "DCTrack+DC.h"
#import "DCBof.h"

#import "DCEventDetailTitleCell.h"
#import "DCEventDetailEmptyCell.h"
#import "DCEventDetailHeader2Cell.h"
#import "DCSpeakerCell.h"
#import "DCDescriptionTextCell.h"


@implementation DCEventDetailViewController

- (instancetype)initWithEvent:(DCEvent *)event
{
    self = [super init];
    if (self)
    {
        _event = event;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [_event.timeRange stringValue];
    self.navigatorBarStyle = EBaseViewControllerNatigatorBarStyleTransparrent;
    self.speakers = [_event.speakers allObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 100, 40)];
    [backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [backButton setExclusiveTouch:YES];
    [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem *backMenuBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backMenuBarButton;
    
}


#pragma mark - UITableView DataSource/Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) // title
        return [DCEventDetailTitleCell cellHeight];

    return [DCEventDetailHeader2Cell cellHeight];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        DCEventDetailTitleCell * titleCell = (DCEventDetailTitleCell*)[tableView dequeueReusableCellWithIdentifier:@"DetailCellIdTitle"];
        [titleCell.titleLbl setText:_event.name];
        return titleCell;
    }
    else if (section == 1)
    {
        DCEventDetailHeader2Cell * infoPanel = (DCEventDetailHeader2Cell*)[tableView dequeueReusableCellWithIdentifier:@"DetailCellIdHeader2"];
        [infoPanel.trackValueLbl setText:[[_event.tracks allObjects].firstObject name]];
        [infoPanel.levelValueLbl setText:_event.level.name];
        [infoPanel.placeValueLbl setText:_event.place];
        [infoPanel.favorBtn setDelegate:self];
        return infoPanel;
    }
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [DCEventDetailEmptyCell cellHeight];
    }
    else if (indexPath.row == _speakers.count) // description cell is the last
    {
        return [DCDescriptionTextCell cellHeightForText:_event.desctiptText];
    }
    return [DCSpeakerCell cellHeight]; // rest should be in section#1 all rows exept last
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    
    return _speakers.count+1; // speakers + description
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdEmpty = @"DetailCellIdEmpty";
    static NSString * cellIdSpeaker = @"DetailCellIdSpeaker";
    static NSString * cellIdDescription = @"DetailCellIdDescription";
    UITableViewCell *cell;
    if (indexPath.section==0)
    {
        if (indexPath.row != 0) {
            NSLog(@"WRONG! event detail cells");
        }
        DCEventDetailEmptyCell * _cell = (DCEventDetailEmptyCell*)[tableView dequeueReusableCellWithIdentifier:cellIdEmpty];
        cell = _cell;
    }
    else if (indexPath.row == _speakers.count) // description cell
    {
        DCDescriptionTextCell * _cell = (DCDescriptionTextCell*)[tableView dequeueReusableCellWithIdentifier:cellIdDescription];
        [_cell.descriptionTxt setText:_event.desctiptText];
        cell = _cell;
    }
    else
    {
        DCSpeaker * speaker = _speakers[indexPath.row];
        DCSpeakerCell * _cell = (DCSpeakerCell*)[tableView dequeueReusableCellWithIdentifier:cellIdSpeaker];
        [_cell.pictureImg setImage:[UIImage imageNamed:@"avatar_test_image"]];
        [_cell.nameLbl setText:speaker.name];
        [_cell.positionTitleLbl setText:speaker.jobTitle];
        cell = _cell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DCSpeakersDetailViewController * speakerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SpeakersDetailViewController"];
    speakerViewController.speaker = _speakers[indexPath.row];
    [self.navigationController pushViewController:speakerViewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _detailTable)
    {
        if (scrollView.contentOffset.y < 0) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0) animated:NO];
        }
        float stopPoint = -1 * (_eventPictureImg.frame.size.height - 64);
        float offsetPoint = -1 * (scrollView.contentOffset.y/2);
        _eventPictureImg.frame = CGRectMake(0,
                                            (offsetPoint > stopPoint ? offsetPoint : stopPoint),
                                            _eventPictureImg.frame.size.width,
                                            _eventPictureImg.frame.size.height);
    }
}

#pragma mark - FavorBtn delegate

- (void)DCFavoriteButton:(DCFavoriteButton *)favoriteButton didChangedState:(BOOL)isSelected
{
    NSLog(@"%@added", (isSelected ? @"" : @"not "));
}

#pragma mark - IBActions

- (void)onBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private

- (NSArray*)DC_speakers_tmp:(NSString*)string
{
    return [string componentsSeparatedByString:@", "];
}

@end
