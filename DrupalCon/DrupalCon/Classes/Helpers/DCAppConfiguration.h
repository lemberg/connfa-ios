//
//  DCAppConfiguration.h
//  DrupalCon
//
//  Created by Olexandr on 8/3/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef HCE

#define SERVER_URL  @"http://harvestcleanenergy.uat.link"
#define BUNDLE_NAME @"HCE-Theme"


#else

#define SERVER_URL  @"http://drupalconbarcelona2015.uat.link"
#define BUNDLE_NAME @"DC-Theme"

#endif
#define BASE_URL [NSString stringWithFormat:@"%@/api/v2/",SERVER_URL]


@interface DCAppConfiguration : NSObject

+ (NSArray *)appMenuItems;
+ (UIColor *)navigationBarColor;
+ (UIColor *)favoriteEventColor;
+ (UIColor *)eventDetailHeaderColour;
+ (UIColor *)eventDetailNavBarTextColor;
+ (UIColor *)speakerDetailBarColor;
+ (BOOL)isFilterEnable;
+ (NSString *)eventTime;
+ (NSString *)eventPlace;
+ (NSString *)appDisplayName;
@end
