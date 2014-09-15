//
//  DCLabel.h
//  DrupalCon
//
//  Created by Macbook on 9/14/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface DCLabel : UILabel
@property (nonatomic, readwrite) VerticalAlignment verticalAlignment;
@end
