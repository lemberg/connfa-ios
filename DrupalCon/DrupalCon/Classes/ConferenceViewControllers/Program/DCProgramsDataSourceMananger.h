//
//  DCProgramsDataSourceMananger.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCEvent.h"

@interface DCProgramsDataSourceMananger : NSObject

-(NSUInteger) days;
-(NSUInteger) sectionsInDay: (int) day;
-(NSUInteger) itemsInDay: (int) day inSection: (int) section;
-(DCEvent*) eventForSection: (int) section row: (int) row inDay: (int)day;
+(instancetype) shared;

@end
