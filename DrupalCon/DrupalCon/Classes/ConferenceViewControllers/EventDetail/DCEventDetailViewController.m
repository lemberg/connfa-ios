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

#import "DCEventDetailViewController.h"
#import "DCSpeakersDetailViewController.h"

#import "DCEvent+DC.h"
#import "DCMainEvent+DC.h"
#import "DCTimeRange+DC.h"
#import "DCSpeaker+DC.h"
#import "DCLevel+DC.h"
#import "DCTrack+DC.h"
#import "DCBof.h"

#import "DCSpeakerCell.h"
#import "DCDescriptionTextCell.h"
#import "UIWebView+DC.h"
#import "DCTime+DC.h"

#import "UIImageView+WebCache.h"
#import "UIConstants.h"
#import "UIImage+Extension.h"


static NSString * cellIdSpeaker = @"DetailCellIdSpeaker";
static NSString * cellIdDescription = @"DetailCellIdDescription";

@interface DCEventDetailViewController ()

@property (nonatomic, weak) IBOutlet UITableView * detailTable;
@property (weak, nonatomic) IBOutlet UIImageView *noDetailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *topBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *topBackgroundShadowView;

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* dateAndPlaceLabel;
@property (nonatomic, weak) IBOutlet UILabel* trackLabel;
@property (nonatomic, weak) IBOutlet UILabel* experienceLabel;
@property (nonatomic, weak) IBOutlet UIImageView* experienceIcon;
@property (nonatomic, weak) IBOutlet UIView* TrackAndLevelView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* topBackgroundTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* headerViewTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* trackAndLevelViewHeight;

@property (nonatomic, weak, readonly) NSArray* speakers;

@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property (nonatomic, strong) NSMutableDictionary *cellsHeight;

@end



@implementation DCEventDetailViewController

#pragma mark - View livecycle

- (instancetype)initWithEvent:(DCEvent *)event
{
    self = [super init];
    if (self)
    {
        _closeCallback = nil;
        _event = event;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self arrangeNavigationBar];
    
    self.cellsHeight = [NSMutableDictionary dictionary];

    self.noDetailImageView.hidden = ![self hideEmptyDetailIcon];
    self.detailTable.scrollEnabled = ![self hideEmptyDetailIcon];
    
    [self updateEventDetailsData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    if (self.closeCallback)
        self.closeCallback();
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - UI initialization

- (void) updateEventDetailsData
{
    self.titleLabel.text = self.event.name;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"MM-dd HH:mm"];
    NSString *date = self.event.date ? [formatter stringFromDate: self.event.date] : @"";
    NSString *place = self.event.place ? self.event.place : @"";
    
    if (date.length && place.length)
        self.dateAndPlaceLabel.text = [NSString stringWithFormat: @"%@ in %@", date, place];
    else
        self.dateAndPlaceLabel.text = [NSString stringWithFormat: @"%@%@", date, place];
    
    
    DCTrack* track = [self.event.tracks anyObject];
    DCLevel* level = self.event.level;
    
    BOOL shouldHideTrackAndLevelView = (track.trackId.integerValue == 0 && level.levelId.integerValue == 0);
    
    if (!shouldHideTrackAndLevelView)
    {
        self.trackLabel.text = [(DCTrack*)[self.event.tracks anyObject] name];
        self.experienceLabel.text = self.event.level.name ? [NSString stringWithFormat:@"Experience level: %@", self.event.level.name] : nil;
        
        UIImage* icon = nil;
        switch (self.event.level.levelId.integerValue)
        {
            case 1:
                icon = [UIImage imageNamed:@"ic_experience_beginner"];
                break;
            case 2:
                icon = [UIImage imageNamed:@"ic_experience_intermediate"];
                break;
            case 3:
                icon = [UIImage imageNamed:@"ic_experience_advanced"];
                break;
            default:
                break;
        }
        self.experienceIcon.image = icon;
    }
    else
    {
        self.trackAndLevelViewHeight.priority = 1000;
        self.TrackAndLevelView.hidden = YES;
    }
}

- (BOOL)isHeaderEmpty
{
    NSString *track = [[_event.tracks allObjects].firstObject name];
    NSString *level = _event.level.name;
    return [level length] == 0 && [track length] == 0;
}

- (void) arrangeNavigationBar
{
    [super arrangeNavigationBar];
    
    self.navigationController.navigationBar.tintColor = NAV_BAR_COLOR;
    [self.navigationController.navigationBar setBackgroundImage: [UIImage imageWithColor:[UIColor clearColor]]
                                                  forBarMetrics: UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem* favoriteButton = [[UIBarButtonItem alloc] initWithImage: self.event.favorite.boolValue ? [UIImage imageNamed:@"star_on"] : [UIImage imageNamed:@"ic_experience_beginner"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(favoriteButtonDidClick:)];
    // tag 1: unselected state
    // tag 2: selected state
    favoriteButton.tag = self.event.favorite.boolValue ? 2 : 1;
    
    UIBarButtonItem* sharedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                  target:self
                                                                                  action:@selector(favoriteButtonDidClick:)];
    
    self.navigationItem.rightBarButtonItems = @[sharedButton, favoriteButton];
}

- (BOOL) hideEmptyDetailIcon
{
    BOOL isHeaderEmpty = [self isHeaderEmpty];
    BOOL isNoSpeakers = ![self.speakers count];
    BOOL isDescriptionEmpty = _event.desctiptText.length == 0;
    return isHeaderEmpty && isNoSpeakers && isDescriptionEmpty;
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

#pragma mark - Private

- (NSArray*) speakers
{
    return [self.event.speakers allObjects];
}

- (void)updateCellAtIndexPath
{
    [self.detailTable beginUpdates];
    [self.detailTable reloadRowsAtIndexPaths:@[self.lastIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.detailTable endUpdates];
}

- (CGFloat) getSpeakerCellHeight
{
    DCSpeakerCell *cell = [self.detailTable dequeueReusableCellWithIdentifier: cellIdSpeaker];
    return cell.frame.size.height;
}

- (float)heightForDescriptionTextCell
{
    float descriptionCellHeight = [DCDescriptionTextCell cellHeightForText:_event.desctiptText];;
    if (self.lastIndexPath && [self.cellsHeight objectForKey:self.lastIndexPath]) {
        descriptionCellHeight = [[self.cellsHeight objectForKey:self.lastIndexPath] floatValue];
    }
    return descriptionCellHeight;
}

#pragma mark - UITableView DataSource/Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.speakers.count) // description cell is the last
    {
        return [self heightForDescriptionTextCell];
    }
    return [self getSpeakerCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        // speakers + description
    return self.speakers.count+1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

        // description cell
    if (indexPath.row == self.speakers.count)
    {
        DCDescriptionTextCell * _cell = (DCDescriptionTextCell*)[tableView dequeueReusableCellWithIdentifier:cellIdDescription];
        _cell.descriptionWebView.delegate = self;
        self.lastIndexPath = indexPath;
        [_cell.descriptionWebView loadHTMLString:_event.desctiptText];
        cell = _cell;
    }
    else // speaker cell
    {
        DCSpeaker * speaker = self.speakers[indexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[DCSpeakerCell class]])
        return;
    
    DCSpeakersDetailViewController * speakerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SpeakersDetailViewController"];
    speakerViewController.speaker = self.speakers[indexPath.row];
    speakerViewController.closeCallback = ^{
        [self.detailTable reloadData];
    };
    [self.navigationController pushViewController:speakerViewController animated:YES];
}

#pragma mark - UIWebView delegate

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

#pragma mark - UIScroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _detailTable)
    {
        float topStopPoint = (self.topBackgroundView.frame.size.height - 20 - 44);
        float offset = scrollView.contentOffset.y;
        
        BOOL shouldMoveToTop = (offset > 0) && (-self.topBackgroundTop.constant*2 < topStopPoint);
        BOOL shouldMoveToBottom = (offset < 0) && (self.topBackgroundTop.constant < 0);
        
            // Nav bar background alpha setting
        float delta = 5;
        float maxAlpha = 0.96;
        float alpha;
        
        if ((-self.topBackgroundTop.constant <= topStopPoint/2) &&
            (-self.topBackgroundTop.constant >= topStopPoint/2-delta))
        {
            alpha = (1 - (topStopPoint/2 + self.topBackgroundTop.constant)/delta) * maxAlpha;
        }
        else
        {
            alpha = (-self.topBackgroundTop.constant >= topStopPoint/2) ? maxAlpha : 0;
        }
        self.topBackgroundShadowView.alpha = alpha;
        
            // constraints setting
        if (shouldMoveToTop)
        {
            self.topBackgroundTop.constant -= scrollView.contentOffset.y/2;
            self.headerViewTop.constant -= scrollView.contentOffset.y/2;
            
                // don't move to Top more it is needed
            if (self.topBackgroundTop.constant < -topStopPoint/2)
                self.topBackgroundTop.constant = -topStopPoint/2;
            
            if (self.headerViewTop.constant < -topStopPoint/2)
                self.headerViewTop.constant = -topStopPoint/2;
            
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0) animated:NO];
        }
        
        if (shouldMoveToBottom)
        {
            self.topBackgroundTop.constant -= scrollView.contentOffset.y/2;
            self.headerViewTop.constant -= scrollView.contentOffset.y/2;
            
                // don't move to Bottom more then it is needed
            if (self.topBackgroundTop.constant >= 0)
                self.topBackgroundTop.constant = 0;
            
            if (self.headerViewTop.constant > 0)
                self.headerViewTop.constant = 0;
            
                // after bounce animatically move to bottom point
            if (scrollView.isDecelerating && scrollView.contentOffset.y <= 0)
            {
                [self.view layoutIfNeeded];
            
                self.topBackgroundTop.constant = 0;
                self.headerViewTop.constant = 0;
                
                [UIView animateWithDuration: 0.3f
                                 animations:^{
                                     self.topBackgroundShadowView.alpha = 0;
                                     [self.view layoutIfNeeded];
                                 }];
            }
            
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0) animated:NO];
        }
    }
}

#pragma mark - User actions

- (void) favoriteButtonDidClick: (UIBarButtonItem*)sender
{
    sender.tag = sender.tag == 1 ? 2 : 1;
    
    BOOL isSelected = (sender.tag == 2);
    
    sender.image = isSelected ? [UIImage imageNamed:@"star_on"] : [UIImage imageNamed:@"ic_experience_beginner"];
    
    self.event.favorite = [NSNumber numberWithBool:isSelected];
    
    if (isSelected)
    {
       // [[DCMainProxy sharedProxy] addToFavoriteEvent:self.event];
    } else {
      //  [[DCMainProxy sharedProxy] removeFavoriteEventWithID:self.event.eventID];
    }
}

@end
