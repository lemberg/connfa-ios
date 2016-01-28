
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
#import "DCSpeakerDetailButtonsCell.h"

#import "UIWebView+DC.h"
#import "UIConstants.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extension.h"
#import "DCEventDetailViewController.h"

static NSString* headerCellId = @"SpeakerDetailHeaderCellId";
static NSString* buttonsCellId = @"SpeakerDetailButtonsCellId";
static NSString* descriptionCellId = @"SpeakerDetailDescriptionCellId";
static NSString* eventCellId = @"SpeakerEventCellId";

@interface DCSpeakersDetailViewController ()<UIWebViewDelegate>

@property(nonatomic, weak) IBOutlet UITableView* speakerTable;
@property(nonatomic, weak) IBOutlet UIView* backgroundView;
@property(nonatomic, weak) IBOutlet UIImageView* backgroundImageView;
@property(nonatomic, weak) IBOutlet UIView* navBarBackgroundView;
@property(nonatomic, weak) IBOutlet UILabel* navBarBackgroundTitleLabel;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint* backgroundViewHeight;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint* backgroundViewTop;

@property(nonatomic, strong) NSIndexPath* descriptionCellIndexPath;
@property(nonatomic, strong) NSMutableDictionary* cellsHeight;
@property(nonatomic, strong) UIColor* currentBarColor;

@property(nonatomic, strong) NSDictionary* cellPrototypes;

@end

@implementation DCSpeakersDetailViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  [self registerScreenLoadAtGA:[NSString stringWithFormat:@"speakerID: %d",
                                                          self.speaker.speakerId
                                                              .intValue]];

  self.cellsHeight = [NSMutableDictionary dictionary];
  self.currentBarColor = [UIColor whiteColor];  // NAV_BAR_COLOR;
  self.navBarBackgroundView.backgroundColor =
      [DCAppConfiguration speakerDetailBarColor];
  self.cellPrototypes = @{
    eventCellId :
        [self.speakerTable dequeueReusableCellWithIdentifier:eventCellId],
    headerCellId :
        [self.speakerTable dequeueReusableCellWithIdentifier:headerCellId],
    buttonsCellId :
        [self.speakerTable dequeueReusableCellWithIdentifier:buttonsCellId]
  };
}

- (void)arrangeNavigationBar {
  [super arrangeNavigationBar];

  //    self.navigationController.navigationBar.tintColor = NAV_BAR_COLOR;
  [self.navigationController.navigationBar
      setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]]
           forBarMetrics:UIBarMetricsDefault];
  self.navigationController.navigationBar.shadowImage = [UIImage new];
  self.navigationController.navigationBar.translucent = YES;
  self.navigationController.navigationBar.backgroundColor =
      [UIColor clearColor];

  self.navBarBackgroundView.alpha = 0;
  self.navBarBackgroundTitleLabel.text = self.speaker.name;
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  if (self.closeCallback) {
    self.closeCallback();
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.navigationController.navigationBar.tintColor = self.currentBarColor;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - Private

- (DCEvent*)eventForIndexPath:(NSIndexPath*)indexPath {
  return [self.speaker.events allObjects][indexPath.row - 3];
}

- (BOOL)isFirstEvent:(NSIndexPath*)indexPath {
  return (indexPath.row == 3);
}

#pragma mark - UITableView Delegate/DataSourse methods

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section {
  return self.speaker.events.count + 3;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  switch (indexPath.row) {
    case 0:  // header cell
    {
      DCSpeakerHeaderCell* cellPrototype = self.cellPrototypes[headerCellId];
      [cellPrototype initData:self.speaker];
      [cellPrototype layoutSubviews];

      CGFloat height =
          [cellPrototype.contentView
              systemLayoutSizeFittingSize:UILayoutFittingCompressedSize]
              .height;

      [self.cellsHeight setObject:[NSNumber numberWithFloat:height]
                           forKey:headerCellId];

      // this hardcoded value sets min cell height to avoid background image
      // scaling. It depends on image size
      self.backgroundViewHeight.constant = height;
      return self.backgroundViewHeight.constant;
    }
    case 1:  // buttons cell
    {
      DCSpeakerDetailButtonsCell* cellPrototype =
      self.cellPrototypes[buttonsCellId];
      // no buttons, self becomes invisible
      if (!self.speaker.webSite.length && !self.speaker.twitterName.length) {
        cellPrototype.separatorView.hidden = true;
        return 0;
      }

      [cellPrototype initData:self.speaker];
      [cellPrototype layoutSubviews];

      return 55.;
    }
    case 2:  // description cell
    {
      if (self.speaker.characteristic.length) {
        if (self.descriptionCellIndexPath &&
            [self.cellsHeight objectForKey:self.descriptionCellIndexPath]) {
          // saved accurate value, estimated after data loading to WebView
          return [[self.cellsHeight
              objectForKey:self.descriptionCellIndexPath] floatValue];
        } else {
          // inaccurate value, used to set cell height before WebView has loaded
          // data, will be replaced after load
          return [DCDescriptionTextCell
              cellHeightForText:self.speaker.characteristic];
        }
      } else {
        DCSpeakerEventCell* cellPrototype = self.cellPrototypes[eventCellId];
        cellPrototype.contentView.hidden = true;
        return 0;
      }
    }
    default:  // speaker event cell
    {
      DCSpeakerEventCell* cellPrototype = self.cellPrototypes[eventCellId];
      [cellPrototype initData:[self eventForIndexPath:indexPath]];
      [cellPrototype layoutSubviews];

      return [cellPrototype.contentView
                 systemLayoutSizeFittingSize:UILayoutFittingCompressedSize]
          .height;
    }
  }
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  UITableViewCell* cell;

  switch (indexPath.row) {
    case 0:  // header cell
    {
      cell = [tableView dequeueReusableCellWithIdentifier:headerCellId];
      [(DCSpeakerHeaderCell*)cell initData:self.speaker];
      break;
    }
    case 1:  // cell with Share buttons (Web and Twitter)
    {
      cell = [tableView dequeueReusableCellWithIdentifier:buttonsCellId];
      [(DCSpeakerDetailButtonsCell*)cell initData:self.speaker];
      break;
    }
    case 2:  // description cell
    {
      cell = [tableView dequeueReusableCellWithIdentifier:descriptionCellId];
      [(DCDescriptionTextCell*)cell descriptionWebView].delegate = self;
      self.descriptionCellIndexPath = indexPath;
      [[(DCDescriptionTextCell*)cell descriptionWebView]
          loadHTMLString:self.speaker.characteristic
                   style:@"event_detail_style"];
      break;
    }
    default:  // speaker's event cell
    {
      DCEvent* event = [self eventForIndexPath:indexPath];
      cell = [tableView dequeueReusableCellWithIdentifier:eventCellId];
      [(DCSpeakerEventCell*)cell initData:event];

      if (!self.speaker.characteristic.length && [self isFirstEvent:indexPath])
        [(DCSpeakerEventCell*)cell separator].hidden = YES;

      break;
    }
  }

  return cell;
}

- (void)tableView:(UITableView*)tableView
    didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  if (indexPath.row >= 3) {
    DCEvent* event = [self eventForIndexPath:indexPath];

    UIStoryboard* storyboard =
        [UIStoryboard storyboardWithName:@"Events" bundle:nil];
    DCEventDetailViewController* detailController = [storyboard
        instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    [detailController setEvent:event];
    [self.navigationController pushViewController:detailController
                                         animated:YES];
  }
}

#pragma mark - User actions

- (IBAction)buttonWebDidClick:(id)sender {
  [[UIApplication sharedApplication]
      openURL:[NSURL URLWithString:_speaker.webSite]];
}

- (IBAction)buttonTwitterDidClick:(id)sender {
  BOOL installed = [[UIApplication sharedApplication]
      canOpenURL:[NSURL URLWithString:@"twitter://"]];

  if (installed) {
    NSString* twitter =
        [NSString stringWithFormat:@"twitter://user?screen_name=%@",
                                   _speaker.twitterName];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitter]];

  } else {
    NSString* twitter = [NSString
        stringWithFormat:@"http://twitter.com/%@", _speaker.twitterName];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitter]];
  }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
  if (scrollView == self.speakerTable) {
    float showNavBarPoint =
        [[self.cellsHeight objectForKey:headerCellId] floatValue];
    float offset = scrollView.contentOffset.y;

    if (offset < 0) {
      [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)
                          animated:NO];
    } else {
      self.backgroundViewTop.constant = -offset / 2;

      float delta = 50;
      float maxAlpha = 0.96;
      float alpha;

      if ((offset <= showNavBarPoint) && (offset >= showNavBarPoint - delta)) {
        alpha = (1 - (showNavBarPoint - offset) / delta) * maxAlpha;
      } else {
        alpha = (offset >= showNavBarPoint) ? maxAlpha : 0;
      }
      self.navBarBackgroundView.alpha = alpha;

      self.navBarBackgroundTitleLabel.textColor = self.currentBarColor;
    }
  }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView*)webView {
  if (![self.cellsHeight objectForKey:self.descriptionCellIndexPath]) {
    float height = [[webView stringByEvaluatingJavaScriptFromString:
                                 @"document.body.scrollHeight;"] floatValue];
    [self.cellsHeight setObject:[NSNumber numberWithFloat:height]
                         forKey:self.descriptionCellIndexPath];

    [self.speakerTable beginUpdates];
    [self.speakerTable
        reloadRowsAtIndexPaths:@[ self.descriptionCellIndexPath ]
              withRowAnimation:UITableViewRowAnimationFade];
    [self.speakerTable endUpdates];
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

@end
