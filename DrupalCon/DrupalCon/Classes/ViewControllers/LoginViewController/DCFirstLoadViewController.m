//
//  DCFirstLoadViewController.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 12/17/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCFirstLoadViewController.h"
#import "DCMainProxy.h"

@interface DCFirstLoadViewController ()

@end

@implementation DCFirstLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[DCMainProxy sharedProxy] setDataReadyCallback:^(DCMainProxyState mainProxyState) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (mainProxyState == DCMainProxyStateDataReady)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
