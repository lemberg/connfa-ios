
#import <UIKit/UIKit.h>

@interface UIWebView (DC)
- (void)loadHTMLString:(NSString*)string;
- (void)loadHTMLString:(NSString*)string style:(NSString*)styleSource;

@end
