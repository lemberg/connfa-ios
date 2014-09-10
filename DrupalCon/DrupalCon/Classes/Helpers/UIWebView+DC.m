//
//  UIWebView+DC.m
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/9/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "UIWebView+DC.h"

@implementation UIWebView (DC)
- (void)loadHTMLString:(NSString *)string
{
    [self loadHTMLString:string baseURL:[self baseURL]];
}

- (NSURL *)baseURL
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    return [NSURL fileURLWithPath:path];
}
@end
