/**********************************************************************************
 *                                                                           
 *  The MIT License (MIT)
 *  Copyright (c) 2015 Lemberg Solutions Limited
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the 
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *   The above copyright notice and this permission notice shall be included in
 *   all  copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM,  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 *  IN THE SOFTWARE.
 *
 *                                                                           
 *****************************************************************************/



#import "NSString+HTML.h"

@implementation NSString (HTML)

// Method based on code obtained from:
// http://www.thinkmac.co.uk/blog/2005/05/removing-entities-from-html-in-cocoa.html
//

- (NSString*)kv_decodeHTMLCharacterEntities {
  if ([self rangeOfString:@"&"].location == NSNotFound) {
    return self;
  } else {
    NSMutableString* escaped = [NSMutableString stringWithString:self];
    NSArray* codes = [NSArray
        arrayWithObjects:@"&nbsp;", @"&iexcl;", @"&cent;", @"&pound;",
                         @"&curren;", @"&yen;", @"&brvbar;", @"&sect;",
                         @"&uml;", @"&copy;", @"&ordf;", @"&laquo;", @"&not;",
                         @"&shy;", @"&reg;", @"&macr;", @"&deg;", @"&plusmn;",
                         @"&sup2;", @"&sup3;", @"&acute;", @"&micro;",
                         @"&para;", @"&middot;", @"&cedil;", @"&sup1;",
                         @"&ordm;", @"&raquo;", @"&frac14;", @"&frac12;",
                         @"&frac34;", @"&iquest;", @"&Agrave;", @"&Aacute;",
                         @"&Acirc;", @"&Atilde;", @"&Auml;", @"&Aring;",
                         @"&AElig;", @"&Ccedil;", @"&Egrave;", @"&Eacute;",
                         @"&Ecirc;", @"&Euml;", @"&Igrave;", @"&Iacute;",
                         @"&Icirc;", @"&Iuml;", @"&ETH;", @"&Ntilde;",
                         @"&Ograve;", @"&Oacute;", @"&Ocirc;", @"&Otilde;",
                         @"&Ouml;", @"&times;", @"&Oslash;", @"&Ugrave;",
                         @"&Uacute;", @"&Ucirc;", @"&Uuml;", @"&Yacute;",
                         @"&THORN;", @"&szlig;", @"&agrave;", @"&aacute;",
                         @"&acirc;", @"&atilde;", @"&auml;", @"&aring;",
                         @"&aelig;", @"&ccedil;", @"&egrave;", @"&eacute;",
                         @"&ecirc;", @"&euml;", @"&igrave;", @"&iacute;",
                         @"&icirc;", @"&iuml;", @"&eth;", @"&ntilde;",
                         @"&ograve;", @"&oacute;", @"&ocirc;", @"&otilde;",
                         @"&ouml;", @"&divide;", @"&oslash;", @"&ugrave;",
                         @"&uacute;", @"&ucirc;", @"&uuml;", @"&yacute;",
                         @"&thorn;", @"&yuml;", nil];

    NSUInteger i, count = [codes count];

    // Html
    for (i = 0; i < count; i++) {
      NSRange range = [self rangeOfString:[codes objectAtIndex:i]];
      if (range.location != NSNotFound) {
        [escaped
            replaceOccurrencesOfString:[codes objectAtIndex:i]
                            withString:[NSString
                                           stringWithFormat:
                                               @"%C", (unsigned short)(160 + i)]
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, [escaped length])];
      }
    }

    // The following five are not in the 160+ range

    // @"&amp;"
    NSRange range = [self rangeOfString:@"&amp;"];
    if (range.location != NSNotFound) {
      [escaped
          replaceOccurrencesOfString:@"&amp;"
                          withString:[NSString
                                         stringWithFormat:@"%C",
                                                          (unsigned short)38]
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [escaped length])];
    }

    // @"&lt;"
    range = [self rangeOfString:@"&lt;"];
    if (range.location != NSNotFound) {
      [escaped
          replaceOccurrencesOfString:@"&lt;"
                          withString:[NSString
                                         stringWithFormat:@"%C",
                                                          (unsigned short)60]
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [escaped length])];
    }

    // @"&gt;"
    range = [self rangeOfString:@"&gt;"];
    if (range.location != NSNotFound) {
      [escaped
          replaceOccurrencesOfString:@"&gt;"
                          withString:[NSString
                                         stringWithFormat:@"%C",
                                                          (unsigned short)62]
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [escaped length])];
    }

    // @"&apos;"
    range = [self rangeOfString:@"&apos;"];
    if (range.location != NSNotFound) {
      [escaped
          replaceOccurrencesOfString:@"&apos;"
                          withString:[NSString
                                         stringWithFormat:@"%C",
                                                          (unsigned short)39]
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [escaped length])];
    }

    // @"&quot;"
    range = [self rangeOfString:@"&quot;"];
    if (range.location != NSNotFound) {
      [escaped
          replaceOccurrencesOfString:@"&quot;"
                          withString:[NSString
                                         stringWithFormat:@"%C",
                                                          (unsigned short)34]
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [escaped length])];
    }

    // Decimal & Hex
    NSRange start, finish, searchRange = NSMakeRange(0, [escaped length]);
    i = 0;

    while (i < [escaped length]) {
      start = [escaped rangeOfString:@"&#"
                             options:NSCaseInsensitiveSearch
                               range:searchRange];

      finish = [escaped rangeOfString:@";"
                              options:NSCaseInsensitiveSearch
                                range:searchRange];

      if (start.location != NSNotFound && finish.location != NSNotFound &&
          finish.location > start.location) {
        NSRange entityRange =
            NSMakeRange(start.location, (finish.location - start.location) + 1);
        NSString* entity = [escaped substringWithRange:entityRange];
        NSString* value =
            [entity substringWithRange:NSMakeRange(2, [entity length] - 2)];

        [escaped deleteCharactersInRange:entityRange];

        if ([value hasPrefix:@"x"]) {
          unsigned tempInt = 0;
          NSScanner* scanner =
              [NSScanner scannerWithString:[value substringFromIndex:1]];
          [scanner scanHexInt:&tempInt];
          [escaped
              insertString:[NSString
                               stringWithFormat:@"%C", (unsigned short)tempInt]
                   atIndex:entityRange.location];
        } else {
          [escaped insertString:[NSString stringWithFormat:@"%C",
                                                           (unsigned short)
                                                               [value intValue]]
                        atIndex:entityRange.location];
        }
        i = start.location;
      } else {
        i++;
      }
      searchRange = NSMakeRange(i, [escaped length] - i);
    }

    return escaped;  // Note this is autoreleased
  }
}

- (NSString*)kv_encodeHTMLCharacterEntities {
  NSMutableString* encoded = [NSMutableString stringWithString:self];

  // @"&amp;"
  NSRange range = [self rangeOfString:@"&"];
  if (range.location != NSNotFound) {
    [encoded replaceOccurrencesOfString:@"&"
                             withString:@"&amp;"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
  }

  // @"&lt;"
  range = [self rangeOfString:@"<"];
  if (range.location != NSNotFound) {
    [encoded replaceOccurrencesOfString:@"<"
                             withString:@"&lt;"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
  }

  // @"&gt;"
  range = [self rangeOfString:@">"];
  if (range.location != NSNotFound) {
    [encoded replaceOccurrencesOfString:@">"
                             withString:@"&gt;"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
  }

  return encoded;
}

@end
