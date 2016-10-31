
#import "DCAboutViewController.h"
#import "UIWebView+DC.h"
#import "UIConstants.h"

#import "DCMainProxy.h"
#import "DCInfo+DC.h"
#import "DCInfoCategory+DC.h"

@interface DCAboutViewController ()<UIWebViewDelegate>
@property(weak, nonatomic) IBOutlet UIWebView* webView;
@property(strong, nonatomic) NSURL* aboutURL;
@end

@implementation DCAboutViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  [self registerScreenLoadAtGA:[NSString
                                   stringWithFormat:@"infoID: %d",
                                                    self.data.infoId.intValue]];

    NSDictionary *titleTextAtributes = self.navigationController.navigationBar.titleTextAttributes;
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.data.name;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [titleTextAtributes valueForKey:@"NSFont"];
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;

  [self.webView loadHTMLString:self.data.html];
  self.webView.scrollView.scrollEnabled = YES;
}

#pragma mark - Private

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - UIWebView delegate

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
