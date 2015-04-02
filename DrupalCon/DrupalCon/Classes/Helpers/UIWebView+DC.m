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

#import "UIWebView+DC.h"
#import "NSString+HTML.h"

@implementation UIWebView (DC)

- (void)loadHTMLString:(NSString *)string style:(NSString*)styleSource
{
    string = (IsEmpty(string))? @"": string;
    NSString *html = [NSString stringWithFormat:@" <!DOCTYPE html> <html> <head><meta http-equiv=\"content-type\" content=\"text/html; charset=ISO-8859-1\"><link rel=\"stylesheet\" type=\"text/css\" href=\"%@.css\"></head><body>%@</body></html> ", styleSource, string];
    
    [self loadHTMLString:html baseURL:[self baseURL]];
    self.scrollView.scrollEnabled = NO;
}

- (void)loadHTMLString:(NSString *)string
{
    [self loadHTMLString:string style:@"style"];
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
