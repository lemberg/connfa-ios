//
//  DCType.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 9/11/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCEvent;

@interface DCType : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * typeID;
@property (nonatomic, retain) NSString * typeIcon;
@property (nonatomic, retain) NSSet *events;
@end

@interface DCType (CoreDataGeneratedAccessors)

- (void)addEventsObject:(DCEvent *)value;
- (void)removeEventsObject:(DCEvent *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
