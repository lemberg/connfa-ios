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

#import "DCBaseViewController.h"
#import "UIConstants.h"

@interface DCBaseViewController ()

@end

@implementation DCBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];

    if (self.navigatorBarStyle == EBaseViewControllerNatigatorBarStyleNormal)
    {
        self.navigationController.navigationBar.barTintColor = NAV_BAR_COLOR;
        NSDictionary *textAttributes = NAV_BAR_TITLE_ATTRIBUTES;
        
        
        self.navigationController.navigationBar.titleTextAttributes = textAttributes;
        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        UIBarButtonItem * backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(onBack)];
        self.navigationItem.backBarButtonItem = backBtn;
        
        if (self.navigationController.viewControllers.count != 1)
        // for all root view controllers 'topItem' is Title not Back Button
        {
            self.navigationController.navigationBar.topItem.title = @"Back";
        }
    }
    else if (self.navigatorBarStyle == EBaseViewControllerNatigatorBarStyleTransparrent)
    {
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;

    }
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];

}

- (void)onBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
