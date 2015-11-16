/**********************************************************************************
 *                                                                           
 *  The MIT License (MIT)
 *  Copyright (c) 2015 Lemberg Solutions Limited
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the 
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *   The above copyright notice and this permission notice shall be included in
 *   all  copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM,  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 *  IN THE SOFTWARE.
 *
 *                                                                           
 *****************************************************************************/





#import <UIKit/UIKit.h>

@class DCEvent;

@protocol DCEventCellProtocol;

@interface DCEventCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UIView* highlightedView;

// Event left section (time and icon)
@property(weak, nonatomic) IBOutlet UIView* leftSectionContainerView;
@property(weak, nonatomic) IBOutlet UILabel* startTimeLabel;
@property(weak, nonatomic) IBOutlet UILabel* endTimeLabel;
@property(weak, nonatomic) IBOutlet UIImageView* eventImageView;

// Event right section
@property(weak, nonatomic) IBOutlet UIView* rightSectionContainerView;
@property(weak, nonatomic) IBOutlet UIImageView* eventLevelImageView;
@property(weak, nonatomic) IBOutlet UILabel* eventTitleLabel;
@property(weak, nonatomic) IBOutlet UILabel* trackLabel;
@property(weak, nonatomic) IBOutlet UILabel* speakersLabel;
@property(weak, nonatomic) IBOutlet UILabel* placeLabel;

@property(weak, nonatomic) IBOutlet UIView* separatorCellView;

@property(nonatomic, setter=isLastCellInSection:) BOOL isLastCellInSection;
@property(nonatomic) BOOL isFirstCellInSection;

@property(weak, nonatomic) id<DCEventCellProtocol> delegate;

- (void)initData:(DCEvent*)event delegate:(id<DCEventCellProtocol>)aDelegate;
- (CGFloat)getHeightForEvent:(DCEvent*)event isFirstInSection:(BOOL)isFirst;

@end

@protocol DCEventCellProtocol<NSObject>
- (void)didSelectCell:(DCEventCell*)eventCell;
@end
