//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DCFavoriteButton.h"

@interface DCFavoriteButton ()

@property (nonatomic, strong) UIImageView * starImg;
@property (nonatomic, strong) UIButton * button;

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
    _starImg = [[UIImageView alloc] initWithFrame:CGRectMake(320 - (16+imgSide), (self.bounds.size.height - imgSide) / 2, imgSide, imgSide)];
    [_starImg setContentMode:UIViewContentModeCenter];
    [_starImg setBackgroundColor:[UIColor clearColor]];
    
    _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_button setFrame:self.bounds];
    [_button setBackgroundColor:[UIColor clearColor]];
    [_button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]];
    [_button addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_starImg];
    [self addSubview:_button];
    
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
    [_starImg setImage:[UIImage imageNamed:(_selected ? @"star_on" : @"star_off_v2")]];
    [self setBackgroundColor:(_selected?[UIColor whiteColor]:[UIColor colorWithRed:239./255. green:52./255. blue:58./255. alpha:1])];
    [_button setTitle:(_selected?@"Remove from your schedule":@"Add to your schedule") forState:UIControlStateNormal];
    [_button setTitleColor:(_selected?[UIColor colorWithRed:239./255. green:52./255. blue:58./255. alpha:1]:[UIColor whiteColor]) forState:UIControlStateNormal];
}

@end
