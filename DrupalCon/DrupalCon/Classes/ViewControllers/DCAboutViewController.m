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

#import "DCAboutViewController.h"
#import "UIWebView+DC.h"
#import "DCMainProxy.h"

@interface DCAboutViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *aboutURL;
@end

@implementation DCAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
       
        // Custom initialization
    }
    return self;
}
- (void)awakeFromNib {
    self.aboutURL = [self aboutResourcePath];
}

- (NSURL *)aboutResourcePath {
    return [[NSBundle mainBundle] URLForResource:@"style" withExtension:@"css"];
}

- (void)loadPage {
//    NSString *html = [NSString stringWithContentsOfURL:self.aboutURL
//                                              encoding:NSUTF8StringEncoding
//                                                 error:nil];
    [[DCMainProxy sharedProxy] loadHtmlAboutInfo:^(NSString *html) {
        html = (IsEmpty(html))? @"": html;
        NSString *content = [NSString stringWithFormat:@" <!DOCTYPE html> <html> <head><meta http-equiv=\"content-type\" content=\"text/html; charset=ISO-8859-1\"><link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"></head><body>%@</body></html> ",
                          html];
        [self.webView loadHTMLString:content baseURL:[self.aboutURL URLByDeletingLastPathComponent]];
    }];
    
}
static inline BOOL IsEmpty(id thing) {
    
    return thing == nil
    
    || ([thing respondsToSelector:@selector(length)]
        
        && [(NSData *)thing length] == 0)
    
    || ([thing respondsToSelector:@selector(count)]
        
        && [(NSArray *)thing count] == 0);
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadPage];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

@end
