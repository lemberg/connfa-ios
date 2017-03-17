
#import "NSDictionary+DC.h"
#import "NSArray+DC.h"

@implementation NSDictionary (DC)

- (NSDictionary*)dictionaryByReplacingNullsWithStrings {
  const NSMutableDictionary* replaced = [self mutableCopy];
  const id nul = [NSNull null];
  const NSString* blank = @"";

  for (NSString* key in self) {
    id object = [self objectForKey:key];
    if (object == nul)
      [replaced setObject:blank forKey:key];
    else if ([object isKindOfClass:[NSDictionary class]])
      [replaced setObject:[object dictionaryByReplacingNullsWithStrings]
                   forKey:key];
    else if ([object isKindOfClass:[NSArray class]])
      [replaced setObject:[object dictionaryByReplacingNullsWithStrings]
                   forKey:key];
  }
  return [NSDictionary dictionaryWithDictionary:[replaced copy]];
}
@end
