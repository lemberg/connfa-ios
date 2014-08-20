//
//  DCMainProxy.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCProgram, DCBof;

@interface DCMainProxy : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;

+ (DCMainProxy*)sharedProxy;

- (void)update;
- (NSArray*)programInstances;
- (NSArray*)bofInstances;
- (NSArray*)typeInstances;
- (DCType*)typeForID:(int)typeID;

- (DCProgram*)createProgramItem;
- (DCBof*)createBofItem;
- (DCType*)createType;

- (void)clearTypes;

@end
