
#import "UIWebView+DC.h"
#import "NSString+HTML.h"

@implementation UIWebView (DC)

- (void)loadHTMLString:(NSString*)string style:(NSString*)styleSource {
  string = (IsEmpty(string)) ? @"" : string;
  NSString *chekedString = [self replaceOccurrencesOfUrlHyperlink:string];
  NSString* html = [NSString
      stringWithFormat:@" <!DOCTYPE html> <html> <head><meta "
                       @"http-equiv=\"content-type\" content=\"text/html; "
                       @"charset=ISO-8859-1\"><link rel=\"stylesheet\" "
                       @"type=\"text/css\" "
                       @"href=\"%@.css\">"
                       @"<meta name=\"format-detection\" content=\"telephone=no\">"
                       @"</head><body>%@</body></html> ",
                       styleSource, chekedString];

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

- (NSString *)replaceOccurrencesOfUrlHyperlink:(NSString *)string {
  NSError *error = nil;
  NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                             error:&error];
  NSString *stringValue = string;
  __block NSMutableString *newString = [[NSMutableString alloc] initWithString:stringValue];
  [detector enumerateMatchesInString:stringValue
                             options:0
                               range:NSMakeRange(0, stringValue.length)
                          usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
     if (result.resultType == NSTextCheckingTypeLink) {
       NSString *strURL =  [stringValue substringWithRange:result.range];
       NSString *link = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", strURL, strURL];
       [newString replaceOccurrencesOfString:strURL withString:link options:NSCaseInsensitiveSearch range:NSMakeRange(0, [stringValue length])];
     }
   }];
  
  return [newString copy];
}

@end
