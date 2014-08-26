//
//  DCEventDetailViewController.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/26/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCEventDetailViewController.h"
#import "DCSpeakerCell.h"
#import "DCEvent+DC.h"
#import "DCProgram+DC.h"
#import "DCTimeRange+DC.h"
#import "DCBof.h"


@interface DCEventDetailViewController ()

@end

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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    [self updateUI];
}

- (void)updateUI
{
    [_eventNameLbl setText:_event.name];
    [_trackLbl setText:_event.track];
    [_levelLbl setText:_event.level];
    [_placeLbl setText:_event.place];
    [_detailTxt setText:_event.desctiptText];
    _speakers = [self DC_speakers_tmp:_event.speakers];
    [_speakersTbl reloadData];
}

#pragma mark - UITableView DataSource/Delegate methods

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _speakers.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdSpeaker = @"DetailCellIdentifierSpeaker";
    UITableViewCell *cell;
    DCSpeakerCell *_cell = (DCSpeakerCell*)[tableView dequeueReusableCellWithIdentifier: cellIdSpeaker];
    [_cell.nameLbl setText:_speakers[indexPath.row]];
    [_cell.positionTitleLbl setText:@"n/a"];
    [_cell.pictureImg setImage:[UIImage imageNamed:@"avatar_test_image"]];
    cell = _cell;
    return _cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"speker selected");
}

#pragma mark - FavorBtn delegate

- (void)DCFavoriteButton:(DCFavoriteButton *)favoriteButton didChangedState:(BOOL)isSelected
{
    NSLog(@"%@added", (isSelected ? @"" : @"not "));
}

#pragma mark - private

- (NSArray*)DC_speakers_tmp:(NSString*)string
{
    return [string componentsSeparatedByString:@", "];
}

@end
