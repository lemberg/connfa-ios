//
//  DCConstants.h
//  DrupalCon
//
//  Created by Roman Malinovskyi on 2/6/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCSideMenuType.h"


@interface DCConstants : NSObject

extern NSString *const testString;
extern NSString *const BASE_URL;
extern NSString *const SERVER_URL;
extern NSString *const BUNDLE_NAME;
extern NSString *const GOOGLE_ANALYTICS_APP_ID;
extern NSString *const TWITTER_API_KEY;
extern NSString *const TWITTER_API_SECRET;

+(NSArray*)appsMenuItems;

@end
