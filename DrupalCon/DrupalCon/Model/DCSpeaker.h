//
//  DCSpeaker.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCEvent;

@interface DCSpeaker : NSManagedObject

@property (nonatomic, retain) NSString * characteristic;
@property (nonatomic, retain) NSString * jobTitle;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * organizationName;
@property (nonatomic, retain) NSNumber * speakerId;
@property (nonatomic, retain) NSSet *events;
@end

@interface DCSpeaker (CoreDataGeneratedAccessors)

- (void)addEventsObject:(DCEvent *)value;
- (void)removeEventsObject:(DCEvent *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
