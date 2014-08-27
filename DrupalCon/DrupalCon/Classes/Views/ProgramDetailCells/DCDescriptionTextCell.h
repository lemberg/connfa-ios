//
//  DCDescriptionTextCell.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/27/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCDescriptionTextCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UITextView * descriptionTxt;

+ (float)cellHeightForText:(NSString*)text;

@end
