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


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self arrangeNavigationBar];
}

- (void) arrangeNavigationBar
{
    if (self.navigatorBarStyle == EBaseViewControllerNatigatorBarStyleNormal)
    {
        self.navigationController.navigationBar.barTintColor = NAV_BAR_COLOR;
        NSDictionary *textAttributes = NAV_BAR_TITLE_ATTRIBUTES;
        
        self.navigationController.navigationBar.titleTextAttributes = textAttributes;
        self.navigationController.navigationBar.translucent = NO;
        
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    }
    else if (self.navigatorBarStyle == EBaseViewControllerNatigatorBarStyleTransparrent)
    {
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
        
    }
    
        // hide annoying 1 px stripe between NavigationBar and controller View
    UIImageView* stripeUnderNavigationBar = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    stripeUnderNavigationBar.hidden = YES;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view
{
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

@end
