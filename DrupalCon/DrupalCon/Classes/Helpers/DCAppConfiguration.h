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
#else
#define SERVER_URL  @"http://drupalconbarcelona2015.uat.link"
#endif
#define BASE_URL [NSString stringWithFormat:@"%@/api/v2/",SERVER_URL]

#define NSBUNDLE_IMAGE(imageName,imageFormat) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:imageFormat]]

@interface DCAppConfiguration : NSObject
+ (NSArray *)appMenuItems;
@end
