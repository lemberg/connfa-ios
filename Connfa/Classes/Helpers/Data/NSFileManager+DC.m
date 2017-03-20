
#import "NSFileManager+DC.h"

@implementation NSFileManager (DC)

+ (NSURL*)appLibraryDirectory {
  return [[[self defaultManager] URLsForDirectory:NSLibraryDirectory
                                        inDomains:NSUserDomainMask] lastObject];
}

@end
