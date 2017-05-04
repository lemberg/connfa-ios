//
//  DCTrack+CoreDataProperties.h
//  Connfa
//
//  Created by Oleh Kurnenkov on 5/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCTrack+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCTrack (CoreDataProperties)

+ (NSFetchRequest<DCTrack *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *order;
@property (nullable, nonatomic, copy) NSNumber *selectedInFilter;
@property (nullable, nonatomic, copy) NSNumber *trackId;
@property (nullable, nonatomic, retain) NSSet<DCEvent *> *events;

@end

@interface DCTrack (CoreDataGeneratedAccessors)

- (void)addEventsObject:(DCEvent *)value;
- (void)removeEventsObject:(DCEvent *)value;
- (void)addEvents:(NSSet<DCEvent *> *)values;
- (void)removeEvents:(NSSet<DCEvent *> *)values;

@end

NS_ASSUME_NONNULL_END
