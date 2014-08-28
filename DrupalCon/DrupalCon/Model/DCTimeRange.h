//
//  DCTimeRange.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCTime;

@interface DCTimeRange : NSManagedObject

@property (nonatomic, retain) DCTime *from;
@property (nonatomic, retain) DCTime *to;

@end
