//
//  NSFileManager+DC.m
//  DrupalCon
//
//  Created by Olexandr on 10/30/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "NSFileManager+DC.h"

@implementation NSFileManager (DC)

+ (NSURL*)appLibraryDirectory {
  return [[[self defaultManager] URLsForDirectory:NSLibraryDirectory
                                        inDomains:NSUserDomainMask] lastObject];
}

@end
