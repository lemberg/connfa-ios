//
//  DCMainProxy.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * INVALID_JSON_EXCEPTION;

@class DCProgram, DCBof, DCType, DCTime, DCTimeRange, DCSpeaker, DCLevel, DCTrack, DCLocation;

@interface DCMainProxy : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;

@property (nonatomic, getter = isDataReady) BOOL dataReady;

+ (DCMainProxy*)sharedProxy;

- (void)dataReadyBlock:(void(^)(BOOL isDataReady, BOOL isUpdatedFromServer))callback;

- (void)update;
- (NSArray*)programInstances;
- (NSArray*)bofInstances;
- (NSArray*)typeInstances;
- (NSArray*)speakerInstances;
- (NSArray*)levelInstances;
- (NSArray*)trackInstances;
- (NSArray *)locationInstances;
- (void)loadHtmlAboutInfo:(void(^)(NSString *))callback;

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
- (DCLocation*)createLocation;

- (void)addToFavoriteEventWithID:(NSNumber *)eventID;
- (void)removeFavoriteEventWithID:(NSNumber *)eventID;
@end
