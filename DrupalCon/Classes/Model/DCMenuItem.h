//
//  DCMenuItem.h
//  DrupalCon
//
//  Created by Roman Malinovskyi on 3/3/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCMenuItem : NSObject

@property (nonatomic, strong) NSString *titleName;
@property (nonatomic, strong) NSString *iconName;
@property (nonatomic, strong) NSString *selectedIconName;
@property (nonatomic, strong) NSString *controllerName;
@property (nonatomic, strong) NSNumber *menuType;


+ (id)initWithTitle:(NSString *)title icon:(NSString *)iconName selectedIcon:(NSString *)selectedIconName controllerId:(NSString *)controllerName andMenuType:(NSNumber *)menuType;



@end
