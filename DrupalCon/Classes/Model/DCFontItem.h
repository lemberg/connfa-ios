//
//  DCFontItem.h
//  DrupalCon
//
//  Created by Roman Malinovskyi on 3/9/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCFontItem : NSObject

@property (nonatomic, strong) NSString *titleFont;
@property (nonatomic, strong) NSString *nameFont;
@property (nonatomic, strong) NSString *descriptionFont;


+ (id)initWithTitleFont:(NSString *)titleFont andNameFont:(NSString *)nameFont andDescriptionFont:(NSString *)descriptionFont;


@end
