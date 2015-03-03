//
//  DCLimitedNavigationController.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 3/3/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

// this controller is used for limiting Stack depth.
// So if we have 10 controllers in stack and MAX_DEPTH == 3, on Back button press we will be returned to previous, and then return to the root.

#import <UIKit/UIKit.h>


typedef void (^CompletionBlock)();


@interface DCLimitedNavigationController : UINavigationController<UINavigationControllerDelegate>

- (instancetype) initWithRootViewController:(UIViewController *)rootViewController completion:(CompletionBlock)aBlock;

@end
