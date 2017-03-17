//
//  DCFontItem.m
//  DrupalCon
//
//  Created by Roman Malinovskyi on 3/9/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCFontItem.h"

@implementation DCFontItem

+ (id)initWithTitleFont:(NSString *)titleFont andNameFont:(NSString *)nameFont andDescriptionFont:(NSString *)descriptionFont {
  
  DCFontItem* item = [[DCFontItem alloc] init];
  item.titleFont = titleFont;
  item.nameFont = nameFont;
  item.descriptionFont = descriptionFont;
  return item;
}


@end
