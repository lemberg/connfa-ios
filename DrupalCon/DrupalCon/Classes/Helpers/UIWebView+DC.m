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
    string = (IsEmpty(string))? @"": string;
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

static inline BOOL IsEmpty(id thing) {
    
    return thing == nil
    
    || ([thing respondsToSelector:@selector(length)]
        
        && [(NSData *)thing length] == 0)
    
    || ([thing respondsToSelector:@selector(count)]
        
        && [(NSArray *)thing count] == 0);
    
}

@end
