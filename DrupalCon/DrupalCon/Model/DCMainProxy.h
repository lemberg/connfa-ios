//
//  DCMainProxy.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCProgram, DCBof, DCType, DCTime, DCTimeRange, DCSpeaker, DCLevel, DCTrack;

@interface DCMainProxy : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;

+ (DCMainProxy*)sharedProxy;

- (void)update;
- (NSArray*)programInstances;
- (NSArray*)bofInstances;
- (NSArray*)typeInstances;
- (NSArray*)speakerInstances;
- (NSArray*)levelInstances;
- (NSArray*)trackInstances;
- (DCType*)typeForID:(int)typeID;
- (DCSpeaker*)speakerForId:(NSInteger)speakerId;
- (DCLevel*)levelForId:(NSInteger)levelId;
- (DCTrack*)trackForId:(NSInteger)trackId;

- (DCProgram*)createProgramItem;
- (DCBof*)createBofItem;
- (DCType*)createType;
- (DCTime*)createTime;
- (DCSpeaker*)createSpeaker;
- (DCTimeRange*)createTimeRange;
- (DCLevel*)createLevel;
- (DCTrack*)createTrack;

@end
