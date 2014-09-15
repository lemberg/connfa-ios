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
#import "UIWebView+DC.h"
#import "DCTime+DC.h"

#import "UIImageView+WebCache.h"

@interface DCEventDetailViewController ()
@property (nonatomic, strong) CloseCallback closeCallback;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property (nonatomic, strong) NSMutableDictionary *cellsHeight;

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
- (BOOL)isHeaderEmpty
{
    NSString *track = [[_event.tracks allObjects].firstObject name];
    NSString *level = _event.level.name;
    return [level length] == 0 && [track length] == 0;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cellsHeight = [NSMutableDictionary dictionary];
    self.title = ([_event.timeRange.from isTimeValid])? [_event.timeRange stringValue] : @"";
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

- (void)didCloseWithCallback:(CloseCallback)callback
{
    self.closeCallback = callback;
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
    
    return [self isHeaderEmpty] ? 75. : [DCEventDetailHeader2Cell cellHeight];
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
        NSString * track = [[_event.tracks allObjects].firstObject name];
        NSString * place = _event.place;
        NSString * level = _event.level.name;

        [infoPanel.trackValueLbl setText:(track.length?track:@"")];
        [infoPanel.levelValueLbl setText:(level.length?level:@"")];
        [infoPanel.placeValueLbl setText:(place.length?place:@"-")];
        [infoPanel.favorBtn setDelegate:self];
        [infoPanel.favorBtn setSelected:[_event.favorite boolValue]];
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
        return [self heightForDescriptionTextCell];
    }
    return [DCSpeakerCell cellHeight]; // rest should be in section#1 all rows exept last
}

- (float)heightForDescriptionTextCell
{
    float descriptionCellHeight = [DCDescriptionTextCell cellHeightForText:_event.desctiptText];;
    if (self.lastIndexPath && [self.cellsHeight objectForKey:self.lastIndexPath]) {
        descriptionCellHeight = [[self.cellsHeight objectForKey:self.lastIndexPath] floatValue];
    }
    return descriptionCellHeight;
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
        if ([self isHeaderEmpty]) {
            [_cell.triangleImageView removeFromSuperview];
        }
        
        cell = _cell;
    }
    else if (indexPath.row == _speakers.count) // description cell
    {
        DCDescriptionTextCell * _cell = (DCDescriptionTextCell*)[tableView dequeueReusableCellWithIdentifier:cellIdDescription];
        _cell.descriptionWebView.delegate = self;
        self.lastIndexPath = indexPath;
        [_cell.descriptionWebView loadHTMLString:_event.desctiptText];
        cell = _cell;
    }
    else
    {
        DCSpeaker * speaker = _speakers[indexPath.row];
        DCSpeakerCell * _cell = (DCSpeakerCell*)[tableView dequeueReusableCellWithIdentifier:cellIdSpeaker];
        [_cell.pictureImg sd_setImageWithURL:[NSURL URLWithString:speaker.avatarPath]
                            placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [_cell setNeedsDisplay];
                                       });
                                   }];
    
        [_cell.nameLbl setText:speaker.name];
        [_cell.positionTitleLbl setText:[self positionTitleForSpeaker:speaker]];
        cell = _cell;
    }
    return cell;
}

- (NSString *)positionTitleForSpeaker:(DCSpeaker *)speaker
{
    NSString *organisationName = speaker.organizationName;
    NSString *jobTitle = speaker.jobTitle;
    if ([jobTitle length] && [organisationName length]) {
        return [NSString stringWithFormat:@"%@ / %@", organisationName, jobTitle];
    }
    if (![jobTitle length]) {
        return organisationName;
    }
    
    return jobTitle;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (![self.cellsHeight objectForKey:self.lastIndexPath]) {
        float height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"] floatValue];
        [self.cellsHeight setObject:[NSNumber numberWithFloat:height] forKey:self.lastIndexPath];
        [self updateCellAtIndexPath];
    }

}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

- (void)updateCellAtIndexPath
{
    [self.detailTable beginUpdates];
    [self.detailTable reloadRowsAtIndexPaths:@[self.lastIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.detailTable endUpdates];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[DCSpeakerCell class]])
        return;
    
    DCSpeakersDetailViewController * speakerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SpeakersDetailViewController"];
    speakerViewController.speaker = _speakers[indexPath.row];
    [speakerViewController didCloseWithCallback:^{
        [self.detailTable reloadData];
    }];
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
    
    self.event.favorite = [NSNumber numberWithBool:isSelected];
    if (isSelected) {
        [[DCMainProxy sharedProxy]
         addToFavoriteEventWithID:self.event.eventID];
    } else {
        [[DCMainProxy sharedProxy]
         removeFavoriteEventWithID:self.event.eventID];
    }
}

#pragma mark - IBActions

- (void)onBack
{
    self.closeCallback();
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private

- (NSArray*)DC_speakers_tmp:(NSString*)string
{
    return [string componentsSeparatedByString:@", "];
}

@end
