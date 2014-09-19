//
//  DCAboutViewController.m
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/1/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCAboutViewController.h"
#import "UIWebView+DC.h"
#import "DCMainProxy.h"

@interface DCAboutViewController ()
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

@end
