//
//  NSCalendar+DC.m
//  DrupalCon
//
//  Created by Sydor Anatolii on 7/22/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "NSCalendar+DC.h"

@implementation NSCalendar (DC)

+ (NSCalendar*)currentGregorianCalendar {
  NSCalendar* gregorian =
      [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  gregorian.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

  return gregorian;
}

@end
