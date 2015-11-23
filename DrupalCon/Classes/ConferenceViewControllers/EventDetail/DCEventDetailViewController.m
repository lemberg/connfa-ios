
#import "DCEventDetailViewController.h"
#import "DCSpeakersDetailViewController.h"

#import "DCEvent+DC.h"
#import "DCMainEvent+DC.h"
#import "DCTimeRange+DC.h"
#import "DCSpeaker+DC.h"
#import "DCBof.h"
#import "DCSpeakerCell.h"
#import "DCDescriptionTextCell.h"
#import "DCEventDetailHeaderCell.h"
#import "UIWebView+DC.h"
#import "DCTime+DC.h"
#import "DCLevel+DC.h"
#import "DCInfo.h"

#import "UIImageView+WebCache.h"
#import "UIConstants.h"
#import "UIImage+Extension.h"
#import "DCCoreDataStore.h"
#import "DCDayEventsController.h"

static NSString* cellIdHeader = @"DetailCellIdHeader";
static NSString* cellIdSpeaker = @"DetailCellIdSpeaker";
static NSString* cellIdDescription = @"DetailCellIdDescription";

@interface DCEventDetailViewController ()

@property(nonatomic, weak) IBOutlet UITableView* tableView;
@property(weak, nonatomic) IBOutlet UIImageView* noDetailImageView;
@property(weak, nonatomic) IBOutlet UIImageView* topBackgroundView;
@property(weak, nonatomic) IBOutlet UIView* topBackgroundShadowView;
@property(weak, nonatomic) IBOutlet UILabel* topTitleLabel;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint* topBackgroundTop;

@property(nonatomic, strong) NSArray* speakers;

@property(nonatomic, strong) NSIndexPath* lastIndexPath;
@property(nonatomic, strong) NSMutableDictionary* cellsHeight;
@property(nonatomic, strong) UIColor* currentBarColor;

@property(nonatomic, strong) NSDictionary* cellsForSizeEstimation;

@end

@implementation DCEventDetailViewController

#pragma mark - View livecycle

- (instancetype)initWithEvent:(DCEvent*)event {
  self = [super init];
  if (self) {
    self.event = event;
  }
  return self;
}

- (void)awakeFromNib {
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.cellsForSizeEstimation = @{
    cellIdHeader :
        [self.tableView dequeueReusableCellWithIdentifier:cellIdHeader],
    cellIdSpeaker :
        [self.tableView dequeueReusableCellWithIdentifier:cellIdSpeaker]
  };

  [self registerScreenLoadAtGA:[NSString stringWithFormat:@"eventID: %d",
                                                          self.event.eventId
                                                              .intValue]];

  self.cellsHeight = [NSMutableDictionary dictionary];

  self.topTitleLabel.text = self.event.name;

  self.noDetailImageView.hidden = ![self hideEmptyDetailIcon];
  self.tableView.scrollEnabled = ![self hideEmptyDetailIcon];
  self.topBackgroundShadowView.backgroundColor =
      [DCAppConfiguration eventDetailHeaderColour];
  [self initSpeakers];
}

- (void)viewWillDisappear:(BOOL)animated {
  if (self.closeCallback)
    self.closeCallback();

  [[DCCoreDataStore defaultStore]
      saveMainContextWithCompletionBlock:^(BOOL isSuccess){
      }];

  [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self arrangeNavigationBar];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleDefault;
}

#pragma mark - UI initialization

- (void)registerScreenLoadAtGA {
  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker set:kGAIScreenName
         value:[NSString
                   stringWithFormat:@"DCEventDetailViewController, eventId: %d",
                                    self.event.eventId.intValue]];
  [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (BOOL)isHeaderEmpty {
  NSString* track = [[_event.tracks allObjects].firstObject name];
  NSString* level = _event.level.name;
  return [level length] == 0 && [track length] == 0;
}

- (void)arrangeNavigationBar {
  self.navigatorBarStyle = EBaseViewControllerNatigatorBarStyleTransparrent;
  [super arrangeNavigationBar];

  self.navigationController.navigationBar.tintColor =
      [DCAppConfiguration navigationBarColor];
  [self.navigationController.navigationBar
      setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]]
           forBarMetrics:UIBarMetricsDefault];
  self.navigationController.navigationBar.shadowImage = [UIImage new];
  self.navigationController.navigationBar.translucent = YES;
  self.navigationController.navigationBar.backgroundColor =
      [UIColor clearColor];
  UIImage* startImage =
      self.event.favorite.boolValue
          ? [[UIImage imageNamedFromBundle:@"star+"]
                imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
          : [[UIImage imageNamedFromBundle:@"star-"]
                imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  UIBarButtonItem* favoriteButton = [[UIBarButtonItem alloc]
      initWithImage:startImage
              style:UIBarButtonItemStylePlain
             target:self
             action:@selector(favoriteButtonDidClick:)];
  // tag 1: unselected state
  // tag 2: selected state
  favoriteButton.tag = self.event.favorite.boolValue ? 2 : 1;

  UIBarButtonItem* sharedButton = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                           target:self
                           action:@selector(shareButtonDidClick)];

  UIColor* eventNavColor = [DCAppConfiguration eventDetailNavBarTextColor];
  self.navigationController.navigationBar.tintColor = eventNavColor;
  self.topTitleLabel.textColor = eventNavColor;
  self.currentBarColor = eventNavColor;

  self.navigationItem.rightBarButtonItems = @[ sharedButton, favoriteButton ];
}

- (BOOL)hideEmptyDetailIcon {
  BOOL isHeaderEmpty = [self isHeaderEmpty];
  BOOL isNoSpeakers = ![self.speakers count];
  BOOL isDescriptionEmpty = _event.desctiptText.length == 0;
  return isHeaderEmpty && isNoSpeakers && isDescriptionEmpty;
}

#pragma mark - Private

- (void)initSpeakers {
  NSArray* sortedSpeakers = [self.event.speakers.allObjects
      sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSInteger first = [(DCSpeaker*)a speakerId].integerValue;
        NSInteger second = [(DCSpeaker*)b speakerId].integerValue;
        return first > second;
      }];

  self.speakers = sortedSpeakers;
}

- (void)updateCellAtIndexPath {
  [self.tableView beginUpdates];
  [self.tableView reloadRowsAtIndexPaths:@[ self.lastIndexPath ]
                        withRowAnimation:UITableViewRowAnimationFade];
  [self.tableView endUpdates];
}

- (CGFloat)getHeaderCellHeight {
  DCEventDetailHeaderCell* cellPrototype =
      self.cellsForSizeEstimation[cellIdHeader];
  [cellPrototype initData:self.event];
  [cellPrototype layoutSubviews];

  CGFloat height =
      [cellPrototype.contentView
          systemLayoutSizeFittingSize:UILayoutFittingCompressedSize]
          .height;
  return height;
}

- (CGFloat)getSpeakerCellHeight:(DCSpeaker*)speaker {
  DCSpeakerCell* cellPrototype = self.cellsForSizeEstimation[cellIdSpeaker];
  [cellPrototype initData:speaker];
  [cellPrototype layoutSubviews];

  CGFloat height =
      [cellPrototype.contentView
          systemLayoutSizeFittingSize:UILayoutFittingCompressedSize]
          .height;
  return height;
}

- (float)heightForDescriptionTextCell {
  float descriptionCellHeight =
      [DCDescriptionTextCell cellHeightForText:_event.desctiptText];
  
  if (self.lastIndexPath &&
      [self.cellsHeight objectForKey:self.lastIndexPath]) {
    descriptionCellHeight =
        [[self.cellsHeight objectForKey:self.lastIndexPath] floatValue];
  }
  return descriptionCellHeight;
}

#pragma mark - UITableView DataSource/Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
  return 1;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  if (indexPath.row == 0)
    return [self getHeaderCellHeight];

  if (indexPath.row == (self.speakers.count + 1))
    return [self heightForDescriptionTextCell];
  else
    return [self getSpeakerCellHeight:self.speakers[indexPath.row - 1]];
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section {
  // speakers + description + header
  return self.speakers.count + 2;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  // header cell
  if (indexPath.row == 0) {
    DCEventDetailHeaderCell* cell = (DCEventDetailHeaderCell*)
        [tableView dequeueReusableCellWithIdentifier:cellIdHeader];
    [cell initData:self.event];
    return cell;
  }

  // description cell
  if (indexPath.row == self.speakers.count + 1) {
    DCDescriptionTextCell* cell = (DCDescriptionTextCell*)
        [tableView dequeueReusableCellWithIdentifier:cellIdDescription];
    cell.descriptionWebView.delegate = self;
    self.lastIndexPath = indexPath;
    [cell.descriptionWebView loadHTMLString:_event.desctiptText
                                      style:@"event_detail_style"];
    return cell;
  } else  // speaker cell
  {
    DCSpeaker* speaker = self.speakers[indexPath.row - 1];
    DCSpeakerCell* cell = (DCSpeakerCell*)
        [tableView dequeueReusableCellWithIdentifier:cellIdSpeaker];
    [cell initData:speaker];
    return cell;
  }
}

- (void)tableView:(UITableView*)tableView
    didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  if (![[tableView cellForRowAtIndexPath:indexPath]
          isKindOfClass:[DCSpeakerCell class]])
    return;
  UIStoryboard* mainStoryboard =
      [UIStoryboard storyboardWithName:@"Speakers" bundle:nil];
  DCSpeakersDetailViewController* speakerViewController = [mainStoryboard
      instantiateViewControllerWithIdentifier:@"SpeakersDetailViewController"];
  speakerViewController.speaker = self.speakers[indexPath.row - 1];
  speakerViewController.closeCallback = ^{
    [self.tableView reloadData];
  };
  [self.navigationController pushViewController:speakerViewController
                                       animated:YES];
}

#pragma mark - UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView*)webView {
  if (![self.cellsHeight objectForKey:self.lastIndexPath]) {
    float height = [[webView stringByEvaluatingJavaScriptFromString:
                                 @"document.body.scrollHeight;"] floatValue];
    [self.cellsHeight setObject:[NSNumber numberWithFloat:height]
                         forKey:self.lastIndexPath];

    NSString* padding = @"document.body.style.margin='0';";
    [webView stringByEvaluatingJavaScriptFromString:padding];

    [self updateCellAtIndexPath];
  }
}

- (BOOL)webView:(UIWebView*)inWeb
    shouldStartLoadWithRequest:(NSURLRequest*)inRequest
                navigationType:(UIWebViewNavigationType)inType {
  if (inType == UIWebViewNavigationTypeLinkClicked) {
    [[UIApplication sharedApplication] openURL:[inRequest URL]];
    return NO;
  }

  return YES;
}

#pragma mark - UIScroll view delegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
  if (scrollView == self.tableView) {
    float topStopPoint = self.topBackgroundView.frame.size.height -
                         self.topBackgroundShadowView.frame.size.height;
    float offset = scrollView.contentOffset.y;

    BOOL shouldMoveToTop =
        (offset > 0) && (-self.topBackgroundTop.constant < topStopPoint);
    BOOL shouldMoveToBottom =
        (offset < 0) && (self.topBackgroundTop.constant <= 0);

    // Nav bar background alpha setting
    float delta = 10;
    float maxAlpha = 1;
    float alpha;

    if ((-self.topBackgroundTop.constant <= topStopPoint) &&
        (-self.topBackgroundTop.constant >= topStopPoint - delta)) {
      alpha = (1 - (topStopPoint + self.topBackgroundTop.constant) / delta) *
              maxAlpha;
    } else {
      alpha = (-self.topBackgroundTop.constant >= topStopPoint) ? maxAlpha : 0;
    }
    self.topBackgroundShadowView.alpha = alpha;

    // constraints setting
    if (shouldMoveToTop) {
      self.topBackgroundTop.constant -= scrollView.contentOffset.y;

      // don't move to Top more it is needed
      if (self.topBackgroundTop.constant < (-topStopPoint))
        self.topBackgroundTop.constant = -topStopPoint;

      [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)
                          animated:NO];
    }

    if (shouldMoveToBottom) {
      self.topBackgroundTop.constant -= scrollView.contentOffset.y;

      // don't move to Bottom more then it is needed
      if (self.topBackgroundTop.constant >= 0)
        self.topBackgroundTop.constant = 0;

      // after bounce animatically move to bottom point
      if (scrollView.isDecelerating && scrollView.contentOffset.y <= 0) {
        [self.view layoutIfNeeded];

        self.topBackgroundTop.constant = 0;

        [UIView animateWithDuration:0.3f
                         animations:^{
                           self.topBackgroundShadowView.alpha = 0;
                           [self.view layoutIfNeeded];
                         }];
      }

      [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)
                          animated:NO];
    }
  }
}

#pragma mark - User actions

- (void)favoriteButtonDidClick:(UIBarButtonItem*)sender {
  sender.tag = sender.tag == 1 ? 2 : 1;

  BOOL isSelected = (sender.tag == 2);

  sender.image =
      isSelected
          ? [[UIImage imageNamedFromBundle:@"star+"]
                imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
          : [[UIImage imageNamedFromBundle:@"star-"]
                imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

  if (isSelected) {
    [[DCMainProxy sharedProxy] addToFavoriteEvent:self.event];
  } else {
    [[DCMainProxy sharedProxy] removeFavoriteEventWithID:self.event];
  }
}

- (void)shareButtonDidClick {
  NSString* invitation = @"Hey, just thought this may be interesting for you: ";
  NSURL* url = [NSURL URLWithString:self.event.link];

  UIActivityViewController* activityController =
      [[UIActivityViewController alloc]
          initWithActivityItems:@[ invitation, url ]
          applicationActivities:nil];

  //    So we have:
  //    UIActivityTypePostToFacebook,
  //    UIActivityTypePostToTwitter,
  //    UIActivityTypeMail,
  //    UIActivityTypeAirDrop
  activityController.excludedActivityTypes = @[
    UIActivityTypePostToWeibo,
    UIActivityTypeMessage,
    UIActivityTypePrint,
    UIActivityTypeCopyToPasteboard,
    UIActivityTypeAssignToContact,
    UIActivityTypeSaveToCameraRoll,
    UIActivityTypeAddToReadingList,
    UIActivityTypePostToFlickr,
    UIActivityTypePostToVimeo,
    UIActivityTypePostToTencentWeibo
  ];

  DCInfo* info =
      [[[DCMainProxy sharedProxy] getAllInstancesOfClass:[DCInfo class]
                                             inMainQueue:YES] lastObject];
  [activityController setValue:info.titleMajor forKey:@"subject"];

  [self presentViewController:activityController animated:YES completion:nil];
}

@end
