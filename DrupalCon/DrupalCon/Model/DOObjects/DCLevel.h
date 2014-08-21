//
//  DCLevel.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/21/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DCLevel : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;

@end
