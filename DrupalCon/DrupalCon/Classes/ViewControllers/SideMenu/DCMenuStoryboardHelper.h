//
//  DCMenuStoryboardHelper.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCSideMenuType.h"
#import "DCEventStrategy.h"

@interface DCMenuStoryboardHelper : NSObject
+(NSString*) viewControllerStoryboardIDFromMenuType: (DCMenuSection) menu;
+(NSString*) titleForMenuType: (DCMenuSection) menu;
+ (BOOL)isProgramOrBof:(DCMenuSection)menu;
+ (DCEventStrategy*)strategyForEventMenuType:(DCMenuSection)menu;

@end
