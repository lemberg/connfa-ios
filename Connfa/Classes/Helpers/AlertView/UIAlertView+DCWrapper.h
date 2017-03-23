//
//  UIAlertView+VCWrapper.h
//  vCarrot
//
//  Created on 3/12/15.
//  Copyright (c) 2015 SRD Industries Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (DCWrapper)

- (void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion;

@end
