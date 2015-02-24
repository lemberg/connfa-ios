//
//  DCFilterCheckBox.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 2/24/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  DCFilterCheckboxDelegateProtocol;

@interface DCFilterCheckBox : UIImageView
{
    BOOL _selected;
}

@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic, weak) id<DCFilterCheckboxDelegateProtocol> delegate;

@end

@protocol DCFilterCheckboxDelegateProtocol <NSObject>

- (void)DCFilterCheckBox:(DCFilterCheckBox*)checkBox didChangedState:(BOOL)isSelected;

@end
