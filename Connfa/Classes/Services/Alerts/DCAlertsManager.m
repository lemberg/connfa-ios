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
  
  NSString *title = [NSString stringWithFormat:@"Event dates are provided in %@ timezone (%li).", timeZoneName, (long)hoursFromGmt];
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Attention" message:title delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:@"Don't show", nil];
  
  
  [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
    // Ok == 0 and Don't Show == 1
    if (buttonIndex == 1) {
      success(YES);
    } else if (buttonIndex == 0) {
      success(NO);
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

+ (void)showAlertControllerWithTitle:(NSString*)title
                             message:(NSString*)msg
                       forController:(UIViewController *)controller{
  UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
  [alertController addAction:okAction];
  [controller presentViewController:alertController animated:true completion:nil];
}

+ (void)showAlertControllerWithTitle:(NSString*)title
                             message:(NSString*)msg
                       forController:(UIViewController *)controller
                              action:(void (^)(UIAlertAction*)) action{
  UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:action];
  [alertController addAction:okAction];
  [controller presentViewController:alertController animated:true completion:nil];
}
@end
