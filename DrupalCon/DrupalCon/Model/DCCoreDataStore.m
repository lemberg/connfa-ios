//
//  DCCoreDataStore.m
//  DrupalCon
//
//  Created by Olexandr on 10/30/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCCoreDataStore.h"
#import "NSFileManager+DC.h"

static NSString *const DCCoreDataModelFileName = @"main";


@interface DCCoreDataStore()

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) NSManagedObjectContext *mainQueueContext;
@property (strong, nonatomic) NSManagedObjectContext *privateQueueContext;

@end

@implementation DCCoreDataStore

+ (instancetype)defaultStore
{
    static DCCoreDataStore *defaultStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStore = [[DCCoreDataStore alloc] init];
    });
    
    return defaultStore;
}

#pragma mark - Singleton Access

+ (NSManagedObjectContext *)mainQueueContext
{
    return [[self defaultStore] mainQueueContext];
}

+ (NSManagedObjectContext *)privateQueueContext
{
    return [[self defaultStore] privateQueueContext];
}


#pragma mark - Getters

- (NSManagedObjectContext *)mainQueueContext
{
    if (!_mainQueueContext) {
        _mainQueueContext = [self newMocWithConcurrencyType:NSMainQueueConcurrencyType];
    }
    
    return _mainQueueContext;
}

- (NSManagedObjectContext *)privateQueueContext
{
    if (!_privateQueueContext) {
        _privateQueueContext = [self newMocWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateQueueContext.parentContext = self.mainQueueContext;
    }
    
    return _privateQueueContext;
}

- (NSManagedObjectContext *)newMocWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type
{
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    moc.persistentStoreCoordinator = self.persistentStoreCoordinator;
    return moc;
}

#pragma mark - Stack Setup

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        NSError *error              = nil;
        BOOL isPesistentStoreAdded  = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                               configuration:nil
                                                                                         URL:[self persistentStoreURL]
                                                                                     options:[self persistentStoreOptions]
                                                                                       error:&error];
        if (!isPesistentStoreAdded) {
            NSLog(@"Error adding persistent store. %@, %@", error, error.userInfo);
        }
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:DCCoreDataModelFileName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    
    return _managedObjectModel;
}

- (NSURL *)persistentStoreURL
{
    NSString *appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    appName = [appName stringByAppendingString:@".sqlite"];
    
    return [[NSFileManager appLibraryDirectory] URLByAppendingPathComponent:appName];
}

- (NSDictionary *)persistentStoreOptions
{
    return @{NSInferMappingModelAutomaticallyOption: @YES, NSMigratePersistentStoresAutomaticallyOption: @YES, NSSQLitePragmasOption: @{@"synchronous": @"OFF"}};
}

@end
