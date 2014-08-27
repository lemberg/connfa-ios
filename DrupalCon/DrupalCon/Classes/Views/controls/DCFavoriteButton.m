//
//  DCFavoriteButton.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/26/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCFavoriteButton.h"

@interface DCFavoriteButton ()

@property (nonatomic, strong) UIImageView * starImg;

@end

@implementation DCFavoriteButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self customization];
    }
    return self;
}

- (void)customization
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    float imgSide = 25.0;
    _starImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 3 * imgSide, (self.bounds.size.height - imgSide) / 2, imgSide, imgSide)];
    [_starImg setBackgroundColor:[UIColor clearColor]];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:self.bounds];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:@"Add to your schedule" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]];
    [button addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_starImg];
    [self addSubview:button];
    
    [self setSelected:NO];
}

- (void)onClick
{
    [self setSelected:!self.selected];
    if (_delegate && [_delegate respondsToSelector:@selector(DCFavoriteButton:didChangedState:)])
    {
        [_delegate DCFavoriteButton:self didChangedState:self.selected];
    }
}

#pragma mark - get/set

- (BOOL)isSelected
{
    return _selected;
}

-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    [_starImg setImage:[UIImage imageNamed:(_selected ? @"star_on" : @"star_off")]];
}

@end
