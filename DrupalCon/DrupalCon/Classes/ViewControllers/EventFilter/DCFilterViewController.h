//
//  DCFilterViewController.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 2/23/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCBaseViewController.h"
#import "DCEventFilterCell.h"

@protocol DCFilterViewControllerDelegate <NSObject>

- (void) filterControllerWillDismiss:(BOOL)cancel;

@end



@interface DCFilterViewController : UITableViewController

@property(nonatomic, weak) id<DCFilterViewControllerDelegate> delegate;

@end
