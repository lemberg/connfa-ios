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
#import "UIWebView+DC.h"
#import "UIConstants.h"
#import "UIImageView+WebCache.h"

@interface DCSpeakersDetailViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) NSArray * events;
@property (nonatomic, weak) IBOutlet UITableView * speakerDetailTbl;
@property (nonatomic, weak) IBOutlet UIView * bgView;
@property (nonatomic, strong) CloseCallback closeCallback;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property (nonatomic, strong) NSMutableDictionary *cellsHeight;
@end

@implementation DCSpeakersDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigatorBarStyle = EBaseViewControllerNatigatorBarStyleTransparrent;
    _events = [_speaker.events allObjects];
    self.cellsHeight = [NSMutableDictionary dictionary];
    [self registerCellsInTableView];
}

static NSString *cellIdEvent = @"cellId_SpeakersEvent";

- (void)registerCellsInTableView
{
    [self.speakerDetailTbl registerClass:[DCSpeakerEventCell class]
            forCellReuseIdentifier:cellIdEvent];
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
        //TODO: refactor!
        UIView * navigatorsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [navigatorsContainer setBackgroundColor:NAV_BAR_COLOR];
        [self.view addSubview:navigatorsContainer];
        
        UIButton* backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [backButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
        [backButton setFrame:CGRectMake(0, 0, 60, 64)];
        [backButton setExclusiveTouch:YES];
        [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [backButton setTitle:@"Back" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton setTintColor:[UIColor whiteColor]];
        [navigatorsContainer addSubview:backButton];
        
        UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
        [titleLbl setTextAlignment:NSTextAlignmentCenter];
        [titleLbl setTextColor:[UIColor whiteColor]];
        [titleLbl setText:@"Speaker Profile"];
        [titleLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:21]];
        [navigatorsContainer addSubview:titleLbl];
        
        [_speakerDetailTbl setFrame:CGRectMake(0, 44, 320, self.view.bounds.size.height-44)];
    }
}

-(void)onBack
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.closeCallback) {
        self.closeCallback();
    }
}
- (void)didCloseWithCallback:(CloseCallback)callback
{
    self.closeCallback = callback;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _speakerDetailTbl)
    {
        float stopPoint = 0;
        float offsetPoint = scrollView.contentOffset.y;
        _bgView.frame = CGRectMake(0,
                                   (offsetPoint < stopPoint ? stopPoint : -1 * offsetPoint),
                                   _bgView.frame.size.width,
                                   _bgView.frame.size.height);
    }
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
        return [self heightForDescriptionTextCell];
    
    else
        return [DCSpeakerEventCell cellHeight];
}

- (float)heightForDescriptionTextCell
{
    float descriptionCellHeight = [DCDescriptionTextCell cellHeightForText:_speaker.characteristic];;
    if (self.lastIndexPath && [self.cellsHeight objectForKey:self.lastIndexPath]) {
        descriptionCellHeight = [[self.cellsHeight objectForKey:self.lastIndexPath] floatValue];
    }
    return descriptionCellHeight;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdHeader = @"cellId_SpeakersHeader";
    static NSString *cellIdBottom = @"cellId_SpeakersBottom";
    
    UITableViewCell *cell;
    
    if (indexPath.row == 0)
    {
        DCSpeakerHeaderCell *_cell = (DCSpeakerHeaderCell*)[tableView dequeueReusableCellWithIdentifier:cellIdHeader];
        [self fillSpeakerHeaderCell:_cell];
        cell = _cell;
    }
    
    else if ([self isLastRow:indexPath.row])
    {
        DCDescriptionTextCell * _cell = (DCDescriptionTextCell*)[tableView dequeueReusableCellWithIdentifier:cellIdBottom];
        _cell.descriptionWebView.delegate = self;
        self.lastIndexPath = indexPath;
        [_cell.descriptionWebView loadHTMLString:_speaker.characteristic];
        cell = _cell;
    }
    
    else // all events cells
    {
        DCEvent * event = _events[indexPath.row-1];
        DCSpeakerEventCell * _cell = (DCSpeakerEventCell*)[tableView dequeueReusableCellWithIdentifier:cellIdEvent];
        [self updateCell:_cell witEvent:event];
        cell = _cell;
    }
    
    return cell;
}

- (void)updateCell:(DCEventBaseCell *)cell witEvent:(DCEvent *)event
{
    NSString *level = event.level.name;
    NSString *track = [[event.tracks allObjects].firstObject name];
    NSString *title = event.name;
    
    NSString *time = [NSString stringWithFormat:@"%@\n%@",[event.date stringForSpeakerEventCell],[event.timeRange stringValue] ];
    NSDictionary *values = nil;

    values = @{
               kHeaderTitle: title,
               kLeftBlockTitle: @"Date",
               kLeftBlockContent: time,
               kMiddleBlockTitle: @"Track",
               kMiddleBlockContent: track,
               kRightBlockTitle: @"Experience Level",
               kRightBlockContent: level
               };

    [cell setValuesForCell: values];
    cell.favoriteButton.selected = [event.favorite boolValue];
    [cell favoriteButtonDidSelected:^(UITableViewCell *cell, BOOL isSelected) {
        [self updateFavoriteItemsInIndexPath:[self.speakerDetailTbl indexPathForCell:cell]
                                   withValue:isSelected];
    }];
    
}
- (void)fillSpeakerHeaderCell:(DCSpeakerHeaderCell *)newCell
{
    
    [newCell.pictureImg sd_setImageWithURL:[NSURL URLWithString:_speaker.avatarPath]
                        placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [newCell setNeedsDisplay];
                                   });
                                   
                               }];
    // Hide label name when organisation is empty
    if (![_speaker.organizationName length]) {
        newCell.organizationTitleLabel.hidden = YES;
    } else {
        newCell.organizationTitleLabel.hidden = NO;

    }
    // Hide label name when job is empty
    if (![_speaker.jobTitle length]) {
        newCell.jobTitleLabel.hidden = YES;
    } else {
        newCell.jobTitleLabel.hidden = NO;
        
    }
    [newCell.nameLbl setText:_speaker.name];
    [newCell.organizationLbl setText:_speaker.organizationName];
    [newCell.jobTitleLbl setText:_speaker.jobTitle];
    if ([_speaker.webSite length]) {
        [newCell.webButton setHidden:NO];
        [newCell.webButton addTarget:self action:@selector(openWebSite:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [newCell.webButton setHidden:YES];
    }
    
    if ([_speaker.twitterName length]) {
        [newCell.twitterButton addTarget:self action:@selector(openTwitterSite:) forControlEvents:UIControlEventTouchUpInside];
        [newCell.twitterButton setHidden:NO];
    } else {
         [newCell.twitterButton setHidden:YES];
    }
    
}

- (void)openWebSite:(id)sender
{
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:_speaker.webSite]];
}

- (void)openTwitterSite:(id)sender
{
    NSString *twitter = [NSString stringWithFormat:@"http://twitter.com/%@", _speaker.twitterName];
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:twitter]];
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
    [self.speakerDetailTbl beginUpdates];
    [self.speakerDetailTbl reloadRowsAtIndexPaths:@[self.lastIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.speakerDetailTbl endUpdates];
}


- (void)updateFavoriteItemsInIndexPath:(NSIndexPath *)anIndexPath
                             withValue:(BOOL)isFavorite {
    DCEvent * event = [self eventFromIndexPath:anIndexPath];
    event.favorite = [NSNumber numberWithBool:isFavorite];
    if (isFavorite) {
        [[DCMainProxy sharedProxy]
         addToFavoriteEvent:event];
    } else {
        [[DCMainProxy sharedProxy]
         removeFavoriteEventWithID:event.eventID];
    }
    
}

- (DCEvent *)eventFromIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row && ![self isLastRow:indexPath.row]) {
        return [self.events objectAtIndex:indexPath.row - 1];
    }
    return nil;
}
#pragma mark -

- (BOOL)isLastRow:(NSInteger)row
{
    return (row == _events.count + 1);
}

@end
