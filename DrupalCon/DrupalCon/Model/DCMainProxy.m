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
    [self updateProgram];
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

- (DCType*)typeForID:(int)typeID
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"typeID == %i",typeID];
    NSArray * results = [self instancesOfClass:[DCType class]
                         filtredUsingPredicate:predicate
                                     inContext:self.managedObjectContext];
    return (results.count ? [results firstObject] : nil);
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

#pragma mark - DO remove

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
    [self clearSpeakers];
    [self DC_generateSpeakers_tmp];
    [self saveContext];
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

- (void)DC_generateSpeakers_tmp
{
    DCSpeaker * speaker = [[DCMainProxy sharedProxy] createSpeaker];
    speaker.name = @"Test SpeakerDB";
    speaker.jobTitle = @"generator";
    speaker.organizationName = @"lemberg LTD";
    speaker.characteristic = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";
}

@end
