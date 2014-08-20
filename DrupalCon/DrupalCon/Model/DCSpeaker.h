//
//  DCSpeaker.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DCSpeaker : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * organizationName;
@property (nonatomic, retain) NSString * jobTitle;
@property (nonatomic, retain) NSString * characteristic;

@end
