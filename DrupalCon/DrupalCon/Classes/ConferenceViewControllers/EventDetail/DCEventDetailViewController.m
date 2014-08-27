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


static float kDCEventDetailSpeakerCellHeight = 65.0;
static float kDCEventInfoPanelTop = 100.0;
static float kDCEventInfoPanelBottom = 244.0;


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
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;

    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 100, 40)];
    [backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [backButton setExclusiveTouch:YES];
    [backButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [backButton setTitle:@"⟨ Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem *backMenuBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backMenuBarButton;
    
    _favoriteBtn.delegate = self;
    [(UIScrollView*)_detailTxt setDelegate:self];
    [(UIScrollView*)_speakersTbl setDelegate:self];
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
    
    float speakersTblY = _speakersTbl.frame.origin.y;
    float speakersTblH = kDCEventDetailSpeakerCellHeight * _speakers.count;
    [_speakersTbl setFrame:CGRectMake(0, speakersTblY, 320, speakersTblH)];
    [_detailTxt setFrame:CGRectMake(0, speakersTblY + speakersTblH, 320, _infoPannel.frame.size.height - (speakersTblY + speakersTblH))];
    
    [_speakersTbl reloadData];
}

#pragma mark - UITableView DataSource/Delegate methods

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kDCEventDetailSpeakerCellHeight;
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

#pragma mark - UIScrollView Delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%@", scrollView);
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
