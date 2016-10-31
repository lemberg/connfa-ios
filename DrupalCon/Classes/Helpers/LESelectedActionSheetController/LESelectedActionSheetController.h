//
//  LESelectedActionSheetController.h
//  LESelectedActionSheetExample
//
//  Created by Serhii Bocharnikov on 6/9/16.
//  Copyright © 2016 Serhii Bocharnikov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LESelectedActionSheetControllerProtocol <NSObject>

- (NSInteger)numberOfActions;
- (NSString *)titleForActionAtIndex:(NSInteger)index;
- (void)performActionAtIndex:(NSInteger)index;

@end

@interface LESelectedActionSheetController : UIViewController

@property (nonatomic) NSUInteger selectedItemIndex;
@property (nonatomic) BOOL requiredSelection;

@property (nonatomic) CGFloat itemHeight;
@property (nonatomic) CGFloat cornerRadius;
@property (strong, nonatomic) UIColor *actionTitleColor;
@property (strong, nonatomic) UIColor *actionTextColor;
@property (strong, nonatomic) UIColor *selectedActionTitleColor;
@property (strong, nonatomic) UIFont *actionTitleFont;
@property (strong, nonatomic) NSString *dismissTitle;
@property (strong, nonatomic) UIColor *dismissTitleColor;
@property (strong, nonatomic) UIColor *dismissTintColor;
@property (strong, nonatomic) UIFont *dismissTitleFont;

@property (weak, nonatomic) id <LESelectedActionSheetControllerProtocol> delegate;

@end