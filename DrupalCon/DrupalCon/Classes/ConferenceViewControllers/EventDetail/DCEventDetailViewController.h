//
//  DCEventDetailViewController.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/26/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFavoriteButton.h"
#import "DCBaseViewController.h"


@class DCEvent, DCProgram, DCBof;
@interface DCEventDetailViewController : DCBaseViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, DCFacotiteDelegateProtocol>

@property (nonatomic, weak) IBOutlet UITableView * detailTable;
@property (nonatomic, weak) IBOutlet UIImageView * eventPictureImg;

@property (nonatomic, strong) DCEvent * event;
@property (nonatomic, strong) NSArray * speakers;

- (instancetype)initWithEvent:(DCEvent*)event;

@end
