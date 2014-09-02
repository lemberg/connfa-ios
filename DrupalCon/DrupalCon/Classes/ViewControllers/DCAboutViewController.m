//
//  DCAboutViewController.m
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/1/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCAboutViewController.h"

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
    return [[NSBundle mainBundle] URLForResource:@"About" withExtension:@"html"];
}

- (void)loadPage {
    NSString *html = [NSString stringWithContentsOfURL:self.aboutURL
                                              encoding:NSUTF8StringEncoding
                                                 error:nil];
    NSURL *resourcesURL = [self.aboutURL URLByDeletingLastPathComponent];
    [self.webView loadHTMLString:html
                         baseURL:resourcesURL];
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
