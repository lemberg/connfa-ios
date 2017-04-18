//
//  DCDeviceType.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 4/18/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCDeviceType.h"

@implementation DCDeviceType

+(BOOL)isIphone5{
  return [self isIphone] && ([self getScreenHeight] == 568.0);
}

+(BOOL)isIphone7{
  return [self isIphone] && ([self getScreenHeight] == 667.0);
}

+(BOOL)isIphone7plus{
  return [self isIphone] && ([self getScreenHeight] == 736.0);
}

+(BOOL)isIphone{
  return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

+(CGFloat)getScreenHeight{
  return [[UIScreen mainScreen] bounds].size.height;
}

@end
