//
//  DCMenuItem.m
//  DrupalCon
//
//  Created by Roman Malinovskyi on 3/3/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCMenuItem.h"


@implementation DCMenuItem

+ (id)initWithTitle:(NSString *)title icon:(NSString *)iconName selectedIcon:(NSString *)selectedIconName controllerId:(NSString *)controllerName andMenuType:(NSNumber*)menuType {

  DCMenuItem* item = [[DCMenuItem alloc] init];
  item.titleName = title;
  item.iconName = iconName;
  item.selectedIconName = selectedIconName;
  item.controllerName = controllerName;
  item.menuType = menuType;
  
  return item;
}


@end

