//
//  DCFavoriteButton.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/26/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  DCFacotiteDelegateProtocol;
@interface DCFavoriteButton : UIView
{
    BOOL _selected;
}

@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic, weak) id<DCFacotiteDelegateProtocol> delegate;

@end

@protocol DCFacotiteDelegateProtocol <NSObject>

- (void)DCFavoriteButton:(DCFavoriteButton*)favoriteButton didChangedState:(BOOL)isSelected;

@end
