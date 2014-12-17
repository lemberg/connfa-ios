//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DCCoreDataStore.h"
#import "DCMainProxy.h"
#import "NSFileManager+DC.h"
#import "NSUserDefaults+DC.h"

static NSString *const DCCoreDataModelFileName = @"main";


@interface DCCoreDataStore()

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) NSManagedObjectContext *privateWriterContext;
@property (strong, nonatomic) NSManagedObjectContext *mainContext;
@property (strong, nonatomic) NSManagedObjectContext *workerContext;

@end

@implementation DCCoreDataStore

+ (instancetype)defaultStore
{
    static DCCoreDataStore *defaultCoreDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCoreDataStore = [[DCCoreDataStore alloc] init];
        // init persistent store - need to be updated if new version of application
        [defaultCoreDataStore persistentStoreCoordinator];
    });
    
    return defaultCoreDataStore;
}

#pragma mark - Singleton Access

+ (NSManagedObjectContext *)mainQueueContext
{
    return [[self defaultStore] mainContext];
}

+ (NSManagedObjectContext *)privateQueueContext
{
    return [[self defaultStore] workerContext];
}

#pragma mark - Public Access

- (void)saveMainContext
{
    [self.mainContext performBlock:^{
        
        // push to parent
        NSError *error;
        if (![self.mainContext save:&error]) {
            // handle error
             NSLog(@"Error saving context %@: %@", self.mainContext, [error localizedDescription]);
        }
        
        // save parent to disk asynchronously
        [self.privateWriterContext performBlock:^{
            NSError *error;
            if (![self.privateWriterContext save:&error]) {
                // handle error
                 NSLog(@"Error saving context %@: %@", self.privateWriterContext, [error localizedDescription]);
            }
        }];
    }];

}

- (BOOL)save
{
    __block NSError *error = nil;
    [self.workerContext performBlockAndWait:^{
        
        // push to parent
        if (![self.workerContext save:&error]) {
            // handle error
            NSLog(@"Error saving context %@: %@", self.workerContext, [error localizedDescription]);
        }
        [self saveMainContext];
    }];
    return !error;
}

#pragma mark - Getters

- (NSManagedObjectContext *)privateWriterContext
{
    if (!_privateWriterContext) {
        _privateWriterContext = [self newMocWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateWriterContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return _privateWriterContext;
}

- (NSManagedObjectContext *)mainContext
{
    if (!_mainContext) {
        _mainContext = [self newMocWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainContext.parentContext = self.privateWriterContext;
    }
    
    return _mainContext;
}

- (NSManagedObjectContext *)workerContext
{
    if (!_workerContext) {
        _workerContext = [self newMocWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _workerContext.parentContext = self.mainContext;
    }
    
    return _workerContext;
}



- (NSManagedObjectContext *)newMocWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type
{
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    return moc;
}

#pragma mark - Stack Setup

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator)
    {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        NSError *error              = nil;
        
        if ([self DC_isNewVersion])
        {
            [[NSFileManager defaultManager] removeItemAtPath:[self persistentStoreURL].path error:&error];
            [[NSFileManager defaultManager] removeItemAtPath:[[self persistentStoreURL].path stringByAppendingString:@"-shm"] error:&error];
            [[NSFileManager defaultManager] removeItemAtPath:[[self persistentStoreURL].path stringByAppendingString:@"-wal"] error:&error];
//            [[DCMainProxy sharedProxy] setState:DCMainProxyStateNoData];
            [NSUserDefaults updateLastModify:@""];
        }
        
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

#pragma mark - 

- (BOOL)DC_isNewVersion
{
    BOOL result = NO;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];

    if ([majorVersion isEqualToString:[NSUserDefaults bundleVersionMajor]] && [minorVersion isEqualToString:[NSUserDefaults bundleVersionMinor]])
    {
        result = NO;
    }
    else
    {
        result = YES;
    }
    [NSUserDefaults saveBundleVersionMajor:majorVersion minor:minorVersion];
    
    return result;
}

@end
