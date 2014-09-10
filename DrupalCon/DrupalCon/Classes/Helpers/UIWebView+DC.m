//
//  UIWebView+DC.m
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/9/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "UIWebView+DC.h"
#import "NSString+HTML.h"

@implementation UIWebView (DC)
- (void)loadHTMLString:(NSString *)string
{
    NSString *html = [NSString stringWithFormat:@" <!DOCTYPE html> <html> <head><meta http-equiv=\"content-type\" content=\"text/html; charset=ISO-8859-1\"><link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"></head><body>%@</body></html> ",
                        string];
    
    [self loadHTMLString:html baseURL:[self baseURL]];
    self.scrollView.scrollEnabled = NO;
}

- (NSURL *)baseURL
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    return [NSURL fileURLWithPath:path];
}
@end
