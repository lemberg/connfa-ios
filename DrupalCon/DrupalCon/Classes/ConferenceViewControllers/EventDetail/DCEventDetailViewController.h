//
//  DCEventDetailViewController.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/26/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFavoriteButton.h"


@class DCEvent, DCProgram, DCBof;
@interface DCEventDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DCFacotiteDelegateProtocol>

@property (nonatomic, weak) IBOutlet UIView * infoPannel;
@property (nonatomic, weak) IBOutlet DCFavoriteButton * favoriteBtn;
@property (nonatomic, weak) IBOutlet UILabel * eventNameLbl;
@property (nonatomic, weak) IBOutlet UILabel * trackLbl;
@property (nonatomic, weak) IBOutlet UILabel * levelLbl;
@property (nonatomic, weak) IBOutlet UILabel * placeLbl;
@property (nonatomic, weak) IBOutlet UITextView * detailTxt;
@property (nonatomic,weak) IBOutlet UITableView * speakersTbl;

@property (nonatomic, strong) DCEvent * event;
@property (nonatomic, strong) NSArray * speakers;

- (instancetype)initWithEvent:(DCEvent*)event;

@end
