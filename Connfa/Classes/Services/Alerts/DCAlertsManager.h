//
//  DCAlertsManager.h
//  DrupalCon
//
//  Created by Olexandr on 2/1/16.
//  Copyright © 2016 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCAlertsManager : NSObject
+ (void)showTimeZoneAlertForTimeZone:(NSTimeZone *)zone
                         withSuccess:(void(^)(BOOL))success;

+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)msg;

@end
