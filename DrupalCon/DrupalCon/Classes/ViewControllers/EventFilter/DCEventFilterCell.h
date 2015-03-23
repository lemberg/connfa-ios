//
//  DCEventFilterCell.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 2/24/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFilterCheckBox.h"


#define FilterCellTypeCount 3

typedef enum {
    FilterCellTypeLevel = 0,
    FilterCellTypeTrack,
    FilterCellTypeButton
} FilterCellType;


@interface DCEventFilterCell : UITableViewCell<DCFilterCheckboxDelegateProtocol>

@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet DCFilterCheckBox *checkBox;
@property (nonatomic, weak) IBOutlet UIView *separator;

@property (nonatomic) FilterCellType type;
@property (nonatomic, weak) NSNumber* relatedObjectId;

@end


