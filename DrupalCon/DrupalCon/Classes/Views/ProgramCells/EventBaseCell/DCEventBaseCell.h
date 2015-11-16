//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in
//   all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE
//  SOFTWARE.
//

#import <UIKit/UIKit.h>
@class DCLabel;

static NSString* const kHeaderTitle = @"HeaderTitle";
static NSString* const kLeftBlockTitle = @"LeftBlocktitle";
static NSString* const kMiddleBlockTitle = @"MiddleBlockTitle";
static NSString* const kRightBlockTitle = @"RightBlockTitle";

static NSString* const kLeftBlockContent = @"LeftBlockContent";
static NSString* const kMiddleBlockContent = @"MiddleBlockContent";
static NSString* const kRightBlockContent = @"RightBlockContent";

typedef void (^FavoriteButtonPressedCallback)(UITableViewCell* cell,
                                              BOOL isSelected);

@interface DCEventBaseCell : UITableViewCell

@property(strong, nonatomic) FavoriteButtonPressedCallback favoriteBtnCallback;

@property(weak, nonatomic) IBOutlet UILabel* title;
@property(weak, nonatomic) IBOutlet UILabel* leftBlockTitle;
@property(weak, nonatomic) IBOutlet UILabel* middleBlockTitle;
@property(weak, nonatomic) IBOutlet UILabel* rightBlockTitle;

@property(weak, nonatomic) IBOutlet DCLabel* leftBlockContent;
@property(weak, nonatomic) IBOutlet DCLabel* middleBlockContent;
@property(weak, nonatomic) IBOutlet UILabel* rightBlockContent;

@property(weak, nonatomic) IBOutlet UIButton* favoriteButton;

- (void)favoriteButtonDidSelected:
    (FavoriteButtonPressedCallback)favoriteButtonPressed;
- (IBAction)favoriteBtnPress:(id)sender;
- (void)setValuesForCell:(NSDictionary*)values;

@end
