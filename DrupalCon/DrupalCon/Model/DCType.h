//
//  DCType.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DCType : NSManagedObject

@property (nonatomic, retain) NSNumber * typeID;
@property (nonatomic, retain) NSString * name;

@end
