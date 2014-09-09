//
//  DCDataProvider.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVER_URL  @"http://amsterdam2014.uat.link/api/"

typedef void (^DataProviderCallBack)(BOOL success, id result);

@interface DCDataProvider : NSObject

+ (void)updateMainDataFromFile:(NSString*)fileName callBack:(DataProviderCallBack)callBack;
+ (void)updateMainDataFromURI:(NSString *)uri callBack:(DataProviderCallBack)callBack;
@end
