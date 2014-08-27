//
//  DCBaseViewController.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCMainProxy.h"

typedef enum {
    EBaseViewControllerNatigatorBarStyleNormal,
    EBaseViewControllerNatigatorBarStyleTransparrent
}EBaseViewControllerNatigatorBarStyle;

@interface DCBaseViewController : UIViewController

@property (nonatomic) EBaseViewControllerNatigatorBarStyle navigatorBarStyle;

@end
