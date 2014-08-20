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

static NSString * kDCMainProxyModelName = @"main";

@interface DCMainProxy ()
{
    NSManagedObjectContext * _backgroundManagedContext;
}

@end

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
                        inContext:[self DC_threadManagedContex]];
}

#pragma mark - DO creation

- (DCProgram*)createProgramItem
{
    return [self createInstanceOfClass:[DCProgram class] inContext:[self DC_threadManagedContex]];
}

- (DCBof*)createBofItem
{
    return [self createInstanceOfClass:[DCBof class] inContext:[self DC_threadManagedContex]];
}

- (NSManagedObjectContext*)DC_threadManagedContex
{
    return ([NSThread isMainThread] ? self.managedObjectContext : _backgroundManagedContext);
}

#pragma mark - DO remove

- (void)clearTypes
{
    [self removeItems:[self typeInstances]
            inContext:[self DC_threadManagedContex]];
}

- (void)removeItems:(NSArray*)items inContext:(NSManagedObjectContext*)context
{
    for (NSManagedObject * object in items)
    {
        [context deleteObject:object];
    }
}

#pragma mark -

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
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _managedObjectContext;
}

#pragma mark -

@end
