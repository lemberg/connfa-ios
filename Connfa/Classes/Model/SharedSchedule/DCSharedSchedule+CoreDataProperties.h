//
//  DCSharedSchedule+CoreDataProperties.h
//  Connfa
//
//  Created by Oleh Kurnenkov on 5/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCSharedSchedule+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCSharedSchedule (CoreDataProperties)

+ (NSFetchRequest<DCSharedSchedule *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *scheduleId;
@property (nullable, nonatomic, copy) NSNumber *isMySchedule;
@property (nullable, nonatomic, retain) NSSet<DCEvent *> *events;

@end

@interface DCSharedSchedule (CoreDataGeneratedAccessors)

- (void)addEventsObject:(DCEvent *)value;
- (void)removeEventsObject:(DCEvent *)value;
- (void)addEvents:(NSSet<DCEvent *> *)values;
- (void)removeEvents:(NSSet<DCEvent *> *)values;

@end

NS_ASSUME_NONNULL_END
