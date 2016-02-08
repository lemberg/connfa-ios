//
//  DCAlertsManager.m
//  DrupalCon
//
//  Created by Olexandr on 2/1/16.
//  Copyright © 2016 Lemberg Solution. All rights reserved.
//

#import "DCAlertsManager.h"
#import "UIAlertView+DCWrapper.h"

@implementation DCAlertsManager

+ (void)showTimeZoneAlertForTimeZone:(NSTimeZone *)zone
                         withSuccess:(void(^)(BOOL))success {
  NSInteger hoursFromGmt = zone.secondsFromGMT / 3600;
  NSString *timeZoneName = zone.name;//[zone localizedName:NSTimeZoneNameStyleGeneric locale:[NSLocale currentLocale]];
  
  NSString *title = [NSString stringWithFormat:@"Event dates are provided in %@ timezone (%li).", timeZoneName, hoursFromGmt];
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Attention" message:title delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:@"Don't show", nil];
  [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
    BOOL isSuccess = buttonIndex != 0;
    if (success) {
      success(isSuccess);
    }
  }];
}

+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)msg {
  [[[UIAlertView alloc] initWithTitle:title
                              message:msg
                             delegate:nil
                    cancelButtonTitle:@"Ok"
                    otherButtonTitles:nil] show];
}

@end
