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





// this controller is used for limiting Stack depth.
// So if we have 10 controllers in stack and MAX_DEPTH == 3, on Back button
// press we will be returned to previous, and then return to the root.
// Also it has fake root VC to show native Back button and dismisses itself
// after last Back button press
// This controller can be shown modally (dismissAction must be nil) or in
// another way (in that case developer should handle last Back button press with
// dismissAction Block)

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)();
typedef void (^BackButtonBlock)();

@interface DCLimitedNavigationController
    : UINavigationController<UINavigationControllerDelegate,
                             UINavigationBarDelegate>

@property(nonatomic) NSInteger maxDepth;

- (instancetype)initWithRootViewController:(UIViewController*)rootViewController
                                completion:(CompletionBlock)aBlock;

- (instancetype)initWithRootViewController:(UIViewController*)rootViewController
                                completion:(CompletionBlock)aBlock
                                     depth:(NSInteger)maxDepth;

- (instancetype)initWithRootViewController:(UIViewController*)rootViewController
                             dismissAction:(BackButtonBlock)aBlock
                                     depth:(NSInteger)maxDepth;

@end
