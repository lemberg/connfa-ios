//
//  DCMainProxy.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCMainProxy.h"
#import "DCProgram+DC.h"
#import "DCBof.h"
#import "DCType+DC.h"
#import "DCTime+DC.h"
#import "DCTimeRange+DC.h"
#import "DCSpeaker+DC.h"
#import "DCLevel+DC.h"
#import "DCTrack+DC.h"
#import "DCLocation+DC.h"

#import "DCDataProvider.h"

static NSString * kDCMainProxyModelName = @"main";

static NSString * kDCMainProxyProgramFile = @"conference";
static NSString * kDCMainProxyTypesFile = @"types";

@implementation DCMainProxy
@synthesize managedObjectModel=_managedObjectModel,
            managedObjectContext=_managedObjectContext,
            persistentStoreCoordinator=_persistentStoreCoordinator;

+ (DCMainProxy*)sharedProxy
{
    static id sharedProxy = nil;
    static dispatch_once_t disp;
    dispatch_once(&disp, ^{
        sharedProxy = [[super alloc] init];
    });
    return sharedProxy;
}

#pragma mark - public

- (void)update
{
    [self updateTypes];
    [self updateSpeakers];
    [self updateLevels];
    [self updateTracks];
    [self updateProgram];
    [self updateLocation];
}

- (NSArray*)programInstances
{
    return [self instancesOfClass:[DCProgram class]
            filtredUsingPredicate:nil
                        inContext:self.managedObjectContext];
}

- (NSArray*)bofInstances
{
    return [self instancesOfClass:[DCBof class]
            filtredUsingPredicate:nil
                        inContext:self.managedObjectContext];
}

- (NSArray*)typeInstances
{
    return [self instancesOfClass:[DCType class]
            filtredUsingPredicate:nil
                        inContext:self.managedObjectContext];
}

- (NSArray*)speakerInstances
{
    return [self instancesOfClass:[DCSpeaker class]
            filtredUsingPredicate:nil
                        inContext:self.managedObjectContext];
}

- (NSArray*)levelInstances
{
    return [self instancesOfClass:[DCLevel class]
            filtredUsingPredicate:nil
                        inContext:self.managedObjectContext];
}

- (NSArray*)trackInstances
{
    return [self instancesOfClass:[DCTrack class]
            filtredUsingPredicate:nil
                        inContext:self.managedObjectContext];
}

- (NSArray *)locationInstances
{
    return [self instancesOfClass:[DCLocation class]
            filtredUsingPredicate:nil
                        inContext:self.managedObjectContext];
}

- (DCType*)typeForID:(NSInteger)typeID
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"typeID == %i",typeID];
    NSArray * results = [self instancesOfClass:[DCType class]
                         filtredUsingPredicate:predicate
                                     inContext:self.managedObjectContext];
    return (results.count ? [results firstObject] : nil);
}

- (DCSpeaker*)speakerForId:(NSInteger)speakerId
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"speakerId == %i", speakerId];
    NSArray * results = [self instancesOfClass:[DCSpeaker class]
                         filtredUsingPredicate:predicate
                                     inContext:self.managedObjectContext];
    if (results.count>1)
        NSLog(@"WRONG! too many speakers for id# %i", speakerId);
        
    return (results.count ? results.firstObject : nil);
}

- (DCLevel*)levelForId:(NSInteger)levelId
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"levelId == %i", levelId];
    NSArray * results = [self instancesOfClass:[DCLevel class]
                         filtredUsingPredicate:predicate
                                     inContext:self.managedObjectContext];
    if (results.count>1)
        NSLog(@"WRONG! too many speakers for id# %i", levelId);
    
    return (results.count ? results.firstObject : nil);
}

- (DCTrack*)trackForId:(NSInteger)trackId
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"trackId == %i", trackId];
    NSArray * results = [self instancesOfClass:[DCTrack class]
                         filtredUsingPredicate:predicate
                                     inContext:self.managedObjectContext];
    if (results.count>1)
        NSLog(@"WRONG! too many speakers for id# %i", trackId);
    
    return (results.count ? results.firstObject : nil);
}

#pragma mark - DO creation

- (DCProgram*)createProgramItem
{
    return [self createInstanceOfClass:[DCProgram class] inContext:self.managedObjectContext];
}

- (DCBof*)createBofItem
{
    return [self createInstanceOfClass:[DCBof class] inContext:self.managedObjectContext];
}

- (DCType*)createType
{
    return [self createInstanceOfClass:[DCType class] inContext:self.managedObjectContext];
}

- (DCTime*)createTime
{
    return [self createInstanceOfClass:[DCTime class] inContext:self.managedObjectContext];
}

- (DCTimeRange*)createTimeRange
{
    return [self createInstanceOfClass:[DCTimeRange class] inContext:self.managedObjectContext];
}

- (DCSpeaker*)createSpeaker
{
    return [self createInstanceOfClass:[DCSpeaker class] inContext:self.managedObjectContext];
}

- (DCLevel*)createLevel
{
    return [self createInstanceOfClass:[DCLevel class] inContext:self.managedObjectContext];
}

- (DCTrack*)createTrack
{
    return [self createInstanceOfClass:[DCTrack class] inContext:self.managedObjectContext];
}

- (DCLocation*)createLocation
{
    return [self createInstanceOfClass:[DCLocation class] inContext:self.managedObjectContext];
}

#pragma mark - DO remove

- (void)clearLevels
{
    [self removeItems:[self levelInstances]
            inContext:self.managedObjectContext];
}
- (void)clearLocation
{
    [self removeItems:[self locationInstances] inContext:self.managedObjectContext];
    
}

- (void)clearTracks
{
    [self removeItems:[self trackInstances]
            inContext:self.managedObjectContext];
}

- (void)clearTypes
{
    [self removeItems:[self typeInstances]
            inContext:self.managedObjectContext];
}

- (void)clearProgram
{
    [self removeItems:[self programInstances]
            inContext:self.managedObjectContext];
}

- (void)clearSpeakers
{
    [self removeItems:[self speakerInstances]
            inContext:self.managedObjectContext];
}

- (void)removeItems:(NSArray*)items inContext:(NSManagedObjectContext*)context
{
    for (NSManagedObject * object in items)
    {
        [context deleteObject:object];
    }
}

#pragma mark - DO save

- (void)saveContext
{
    NSError * err = nil;
    [self.managedObjectContext save:&err];
    if (err)
    {
        NSLog(@"WRONG! context save");
    }
}

#pragma mark -

- (void)updateProgram
{
    [self. managedObjectContext performBlock:^{
        [DCDataProvider updateMainDataFromFile:kDCMainProxyProgramFile callBack:^(BOOL success, id result) {
            if (success && result)
            {
                [self clearProgram];
                [DCProgram parceFromJSONData:result];
                [self saveContext];
            }
            else
            {
                NSLog(@"%@", result);
            }
        }];
    }];
}

- (void)updateTypes
{
    [self.managedObjectContext performBlockAndWait:^{
       [DCDataProvider updateMainDataFromFile:kDCMainProxyTypesFile callBack:^(BOOL success, id result) {
           if (success && result)
           {
               [self clearTypes];
               [DCType parceFromJsonData:result];
               [self saveContext];
           }
           else
           {
               NSLog(@"%@", result);
           }
       }];
    }];
}


- (void)updateSpeakers
{
    [self.managedObjectContext performBlockAndWait:^{
        [DCDataProvider updateMainDataFromFile:[NSString stringWithFormat:@"%@",[NSStringFromClass([DCSpeaker class]) lowercaseString]] callBack:^(BOOL success, id result) {
            if (success && result)
            {
                [self clearSpeakers];
                [DCSpeaker parceFromJSONData:result];
                [self saveContext];
            }
            else
            {
                NSLog(@"WRONG! %@", result);
            }
        }];
    }];
}

- (void)updateLevels
{
    [self.managedObjectContext performBlockAndWait:^{
        [DCDataProvider updateMainDataFromFile:[self DC_fileNameForClass:[DCLevel class]] callBack:^(BOOL success, id result) {
            if (success && result)
            {
                [self clearLevels];
                [DCLevel parceFromJsonData:result];
                [self saveContext];
            }
            else
            {
                NSLog(@"WRONG! %@", result);
            }
        }];
    }];
}

- (void)updateTracks
{
    [self.managedObjectContext performBlockAndWait:^{
        [DCDataProvider updateMainDataFromFile:[self DC_fileNameForClass:[DCTrack class]] callBack:^(BOOL success, id result) {
            if (success && result)
            {
                [self clearTracks];
                [DCTrack parceFromJsonData:result];
                [self saveContext];
            }
            else
            {
                NSLog(@"WRONG! %@", result);
            }
        }];
    }];
}

- (void)updateLocation
{
    [self.managedObjectContext performBlockAndWait:^{
        [DCDataProvider updateMainDataFromFile:[self DC_fileNameForClass:[DCLocation class]] callBack:^(BOOL success, id result) {
            if (success && result)
            {
                [self clearLocation];
                [DCLocation parceFromJsonData:result];
                [self saveContext];
            }
            else
            {
                NSLog(@"WRONG! %@", result);
            }
        }];
    }];
}

- (NSArray*) instancesOfClass:(Class)objectClass filtredUsingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    @try {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(objectClass) inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entityDescription];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        [fetchRequest setPredicate:predicate];
        NSArray *result = [context executeFetchRequest:fetchRequest error:nil];
        if(result && [result count])
        {
            return result;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", [context description]);
        NSLog(@"%@", [context.persistentStoreCoordinator description]);
        NSLog(@"%@", [context.persistentStoreCoordinator.managedObjectModel description]);
        NSLog(@"%@", [context.persistentStoreCoordinator.managedObjectModel.entities description]);
        @throw exception;
    }
    @finally {
        
    }
    return nil;
}

- (id) createInstanceOfClass:(Class)instanceClass inContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(instanceClass)  inManagedObjectContext:context];
    NSManagedObject *result = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
    return result;
}

#pragma mark - Core Data stack

- (NSManagedObjectModel*)managedObjectModel
{
    if (!_managedObjectModel)
    {
        NSURL * modelURL = [[NSBundle mainBundle] URLForResource:kDCMainProxyModelName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator)
    {
        NSString * dbName = [NSString stringWithFormat:@"%@.sqlite",kDCMainProxyModelName];
        NSURL * cachURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [cachURL URLByAppendingPathComponent:dbName];
        
        NSError * err = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                      configuration:nil
                                                                URL:storeURL
                                                            options:nil
                                                              error:&err])
        {
            NSLog(@"Unresolved error %@, %@", err, [err userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext*)managedObjectContext
{
    if (!_managedObjectModel)
    {
        NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
        if (coordinator)
        {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _managedObjectContext;
}

#pragma mark -

- (NSString*)DC_fileNameForClass:(__unsafe_unretained Class)aClass
{
    return [NSStringFromClass(aClass) lowercaseString];
}
@end
