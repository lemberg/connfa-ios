//
//  DCLocation.h
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/3/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DCLocation : NSManagedObject

@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) NSString *latitude;
// Place name
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *streetName;
// Building number
@property (nonatomic, retain) NSString *number;

@end
