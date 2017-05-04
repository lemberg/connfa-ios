//
//  DCLevel+CoreDataProperties.h
//  Connfa
//
//  Created by Oleh Kurnenkov on 5/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCLevel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCLevel (CoreDataProperties)

+ (NSFetchRequest<DCLevel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *levelId;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *order;
@property (nullable, nonatomic, copy) NSNumber *selectedInFilter;
@property (nullable, nonatomic, retain) NSSet<DCEvent *> *events;

@end

@interface DCLevel (CoreDataGeneratedAccessors)

- (void)addEventsObject:(DCEvent *)value;
- (void)removeEventsObject:(DCEvent *)value;
- (void)addEvents:(NSSet<DCEvent *> *)values;
- (void)removeEvents:(NSSet<DCEvent *> *)values;

@end

NS_ASSUME_NONNULL_END
