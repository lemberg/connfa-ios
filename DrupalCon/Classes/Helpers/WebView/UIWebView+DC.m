
#import "UIWebView+DC.h"
#import "NSString+HTML.h"

@implementation UIWebView (DC)

- (void)loadHTMLString:(NSString*)string style:(NSString*)styleSource {
  string = (IsEmpty(string)) ? @"" : string;
  NSString* html = [NSString
      stringWithFormat:@" <!DOCTYPE html> <html> <head><meta "
                       @"http-equiv=\"content-type\" content=\"text/html; "
                       @"charset=ISO-8859-1\"><link rel=\"stylesheet\" "
                       @"type=\"text/css\" "
                       @"href=\"%@.css\"></head><body>%@</body></html> ",
                       styleSource, string];

  [self loadHTMLString:html baseURL:[self baseURL]];
  self.scrollView.scrollEnabled = NO;
}

- (void)loadHTMLString:(NSString*)string {
  [self loadHTMLString:string style:@"style"];
}

- (NSURL*)baseURL {
  NSString* path = [[NSBundle mainBundle] bundlePath];
  return [NSURL fileURLWithPath:path];
}

static inline BOOL IsEmpty(id thing) {
  return thing == nil

         || ([thing respondsToSelector:@selector(length)]

             && [(NSData*)thing length] == 0)

         ||
         ([thing respondsToSelector:@selector(count)]

          && [(NSArray*)thing count] == 0);
}

@end
