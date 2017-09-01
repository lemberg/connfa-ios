//
//  DCSpeaker+CoreDataProperties.h
//  Connfa
//
//  Created by Oleh Kurnenkov on 5/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCSpeaker+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCSpeaker (CoreDataProperties)

+ (NSFetchRequest<DCSpeaker *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *avatarPath;
@property (nullable, nonatomic, copy) NSString *characteristic;
@property (nullable, nonatomic, copy) NSString *firstName;
@property (nullable, nonatomic, copy) NSString *jobTitle;
@property (nullable, nonatomic, copy) NSString *lastName;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *order;
@property (nullable, nonatomic, copy) NSString *organizationName;
@property (nullable, nonatomic, copy) NSString *sectionKey;
@property (nullable, nonatomic, copy) NSNumber *speakerId;
@property (nullable, nonatomic, copy) NSString *twitterName;
@property (nullable, nonatomic, copy) NSString *webSite;
@property (nullable, nonatomic, retain) NSSet<DCEvent *> *events;

@end

@interface DCSpeaker (CoreDataGeneratedAccessors)

- (void)addEventsObject:(DCEvent *)value;
- (void)removeEventsObject:(DCEvent *)value;
- (void)addEvents:(NSSet<DCEvent *> *)values;
- (void)removeEvents:(NSSet<DCEvent *> *)values;

@end

NS_ASSUME_NONNULL_END
