//
//  DCMainProxy.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCMainProxy.h"
#import "DCEvent+DC.h"
#import "DCProgram+DC.h"
#import "DCBof.h"
#import "DCType+DC.h"
#import "DCTime+DC.h"
#import "DCTimeRange+DC.h"
#import "DCSpeaker+DC.h"
#import "DCLevel+DC.h"
#import "DCTrack+DC.h"
#import "DCLocation+DC.h"
#import "DCFavoriteEvent.h"
#import "NSDate+DC.h"

#import "Reachability.h"
#import "DCDataProvider.h"
#import "AppDelegate.h"

const NSString * INVALID_JSON_EXCEPTION = @"Invalid JSON";
static NSString * kDCMainProxyModelName = @"main";

static NSString * kDCMainProxyProgramFile = @"conference";
static NSString * kDCMainProxyTypesFile = @"types";
static NSString * kTimeStampSynchronisation = @"lastUpdate";
static NSString * kAboutInfo = @"aboutHTML";

static NSString *const TYPES_URI = @"getTypes";
static NSString *const SPEKERS_URI = @"getSpeakers";
static NSString *const LEVELS_URI = @"getLevels";
static NSString *const TRACKS_URI = @"getTracks";
static NSString *const PROGRAMS_URI = @"getPrograms";
static NSString *const BOFS_URI = @"getBofs";
static NSString *const TIME_STAMP_URI = @"getLastUpdate";
static NSString *const ABOUT_INFO_URI = @"getAbout";
static NSString *const LOCATION_URI = @"getLocations";

typedef void(^UpdateDataFail)(NSString *reason);
@interface DCMainProxy ()
@property (nonatomic, copy) void(^dataReadyCallback)(BOOL isDataReady);
@property (nonatomic, getter = isDataReady) BOOL dataReady;
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

- (void)dataReadyBlock:(void(^)(BOOL isDataReady))callback
{
    callback(self.isDataReady);
    self.dataReadyCallback = callback;
}

- (void)startNetworkChecking
{
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"google.com"];
    
    reach.reachableBlock = ^(Reachability * reachability)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [self updateEvents];
            if (self.dataReadyCallback) {
                self.dataReadyCallback(self.isDataReady);
            }

            
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self savedValueForKey:kTimeStampSynchronisation]) {
                self.dataReady = YES;
                if (self.dataReadyCallback) {
                    self.dataReadyCallback(self.isDataReady);
                }
            }
        });
    };
    
    [reach startNotifier];

}

#pragma mark - public

- (void)update
{

    self.dataReady = NO;
    [self startNetworkChecking];

}

- (void)updateEvents
{

    [self timeStamp:^(NSString *timeStamp) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        if ([self updateTimeStampSynchronisation:timeStamp]) {

            [self showRootController];
            __block BOOL isUpdateFail = NO;
            UpdateDataFail updateFail = ^(NSString *reason){
                isUpdateFail = YES;
            };
            [self updateTypesCallback:updateFail];
            [self updateSpeakersCallback:updateFail];
            [self updateLevelsCallback:updateFail];
            [self updateTracksCallback:updateFail];
            [self updateProgramCallback:updateFail];
            [self updateBofsCallback:updateFail];
            [self updateLocationCallback:updateFail];
            [self synchrosizeFavoritePrograms];
            if (!isUpdateFail) {
                [self saveObject:timeStamp forKey:kTimeStampSynchronisation];
                self.dataReady = YES;
            } else {
                [self saveObject:@"" forKey:kTimeStampSynchronisation];
                self.dataReady = NO;
            }

        } else {
             self.dataReady = YES;
        }
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}
- (void)showRootController
{
    // root in this case meens Side menu
    UINavigationController *navController = (UINavigationController *)[(AppDelegate*)[[UIApplication sharedApplication] delegate] window].rootViewController;
    [[navController topViewController] dismissViewControllerAnimated:YES completion:nil];
    [navController popToViewController:navController.viewControllers[0] animated:NO];
                                                                       
}

- (void)saveObject:(NSObject *)obj forKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:obj forKey:key];
    [userDefaults synchronize];
}

- (id)savedValueForKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:key];
}

- (BOOL)updateTimeStampSynchronisation:(NSString *)timeStamp
{
    NSString *lastUpdateTime = [self savedValueForKey:kTimeStampSynchronisation];
    if (!lastUpdateTime || ![lastUpdateTime isEqualToString: timeStamp]) {
        return YES;
    }
    return NO;
    
}

- (void)timeStamp:(void(^)(NSString *timeStamp))callback
{
    [DCDataProvider
     updateMainDataFromURI:TIME_STAMP_URI
     callBack:^(BOOL success, id result) {
         if (success && result) {
             NSError *err;
             NSDictionary * tracks = [NSJSONSerialization JSONObjectWithData:result
                                                                     options:kNilOptions
                                                                       error:&err];
             callback([tracks objectForKey:kTimeStampSynchronisation]);
         }
         else {
             NSLog(@"%@", result);
         }
     }];
}

- (void)synchrosizeFavoritePrograms
{
    //    synchronize
    NSArray *favoriteEventIDs = [self favoriteInstanceIDs];
    if (!favoriteEventIDs) return;
    NSMutableArray *favorteIDs = [NSMutableArray array];
    for (NSDictionary *favorite in favoriteEventIDs) {
        [favorteIDs addObjectsFromArray:[favorite allValues]];
    }
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"eventID IN %@", favorteIDs];
    NSArray * results = [self instancesOfClass:[DCEvent class]
                         filtredUsingPredicate:predicate
                                     inContext:self.managedObjectContext];
    for (DCEvent *program in results) {
        program.favorite = [NSNumber numberWithBool:YES];
    }
    [self saveContext];
    
}

- (NSArray *)favoriteInstanceIDs
{
    return [self valuesFromProperties:@[@"eventID"]
                   forInstanceOfClass:[DCFavoriteEvent class]
                            inContext:self.managedObjectContext];
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
        NSLog(@"WRONG! too many speakers for id# %li", (long)speakerId);
    
    return (results.count ? results.firstObject : nil);
}

- (DCLevel*)levelForId:(NSInteger)levelId
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"levelId == %i", levelId];
    NSArray * results = [self instancesOfClass:[DCLevel class]
                         filtredUsingPredicate:predicate
                                     inContext:self.managedObjectContext];
    if (results.count>1)
        NSLog(@"WRONG! too many speakers for id# %li", (long)levelId);
    
    return (results.count ? results.firstObject : nil);
}

- (DCTrack*)trackForId:(NSInteger)trackId
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"trackId == %i", trackId];
    NSArray * results = [self instancesOfClass:[DCTrack class]
                         filtredUsingPredicate:predicate
                                     inContext:self.managedObjectContext];
    if (results.count>1)
        NSLog(@"WRONG! too many speakers for id# %li", (long)trackId);
    
    return (results.count ? results.firstObject : nil);
}

- (DCFavoriteEvent *)favoriteEventFromID:(NSInteger)eventID
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"eventID == %i", eventID];
    NSArray * results = [self instancesOfClass:[DCFavoriteEvent class]
                         filtredUsingPredicate:predicate
                                     inContext:self.managedObjectContext];
    if (results.count>1)
        NSLog(@"WRONG! too many favorite events for id# %li", (long)eventID);
    
    return (results.count ? results.firstObject : nil);
}

#pragma mark - Operation with favorites

- (void)addToFavoriteEventWithID:(NSNumber *)eventID
{
    DCFavoriteEvent *favoriteEvent = [self createFavoriteEvent];
    favoriteEvent.eventID = eventID;
    [self saveContext];
}

- (void)removeFavoriteEventWithID:(NSNumber *)eventID
{
    DCFavoriteEvent *event = [self favoriteEventFromID:[eventID integerValue]];
    if (event) {
        [self removeItems:@[event]
                inContext:self.managedObjectContext];
    }
    [self saveContext];
}

- (void)loadHtmlAboutInfo:(void(^)(NSString *))callback
{
// FIXME: change ABOUT_INFO_URI value
    [self.managedObjectContext performBlockAndWait:^{
        [DCDataProvider
         updateMainDataFromURI:ABOUT_INFO_URI
         callBack:^(BOOL success, id result) {
             if (success && result)
             {
                 NSError *error;
                 NSDictionary * about  = [NSJSONSerialization JSONObjectWithData:result
                                                                         options:kNilOptions
                                                                           error:&error];
                 callback([about objectForKey:kAboutInfo]);
                 [self saveObject:[about objectForKey:kAboutInfo] forKey:kAboutInfo];
             }
             else
             {
                 if ([self savedValueForKey:kAboutInfo]) {
                     callback([self savedValueForKey:kAboutInfo]);
                 } else {
                     callback(@"");
                 }
                 
                 NSLog(@"WRONG! %@", result);
             }
         }];
    }];
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

- (DCFavoriteEvent *)createFavoriteEvent
{
    return [self createInstanceOfClass:[DCFavoriteEvent class] inContext:self.managedObjectContext];
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

- (void)clearBofs
{
    [self removeItems:[self bofInstances]
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

- (void)updateProgramCallback:(UpdateDataFail)callback
{
    [self. managedObjectContext performBlock:^{
        [DCDataProvider
         updateMainDataFromURI:PROGRAMS_URI
         callBack:^(BOOL success, id result) {
             if (success && result)
             {
                 @try {
                     [self clearProgram];
                     [DCProgram parseFromJSONData:result];
                     [self saveContext];
                 }
                 @catch (NSException *exception) {
                     callback([exception name]);
                 }
             }
             else
             {
                 NSLog(@"%@", result);
             }
         }];
    }];
}

- (void)updateBofsCallback:(UpdateDataFail)callback
{
    [self. managedObjectContext performBlock:^{
        [DCDataProvider
         updateMainDataFromURI:BOFS_URI
         callBack:^(BOOL success, id result) {
             if (success && result)
             {
                 @try {
                     [self clearBofs];
                     [DCBof parseFromJSONData:result];
                     [self saveContext];                }
                 @catch (NSException *exception) {
                     callback([exception name]);
                 }
             }
             else
             {
                 NSLog(@"%@", result);
             }
         }];
    }];
}

- (void)updateTypesCallback:(UpdateDataFail)callback
{
    [self.managedObjectContext performBlockAndWait:^{
        [DCDataProvider
         updateMainDataFromURI:TYPES_URI
         callBack:^(BOOL success, id result) {
             if (success && result)
             {
                 @try {
                     [self clearTypes];
                     [DCType parseFromJsonData:result];
                     [self saveContext];                 }
                 @catch (NSException *exception) {
                     callback([exception name]);
                 }
             }
             else
             {
                 NSLog(@"%@", result);
             }
         }];
    }];
}


- (void)updateSpeakersCallback:(UpdateDataFail)callback
{
    [self.managedObjectContext performBlockAndWait:^{
        [DCDataProvider
         updateMainDataFromURI:SPEKERS_URI
         callBack:^(BOOL success, id result) {
             if (success && result)
             {
                 @try {
                     [self clearSpeakers];
                     [DCSpeaker parseFromJSONData:result];
                     [self saveContext];               }
                 @catch (NSException *exception) {
                     callback([exception name]);
                 }
             }
             else
             {
                 NSLog(@"WRONG! %@", result);
             }
         }];
    }];
}

- (void)updateLevelsCallback:(UpdateDataFail)callback
{
    [self.managedObjectContext performBlockAndWait:^{
        [DCDataProvider
         updateMainDataFromURI:LEVELS_URI
         callBack:^(BOOL success, id result) {
             if (success && result)
             {
                 @try {
                     [self clearLevels];
                     [DCLevel parseFromJsonData:result];
                     [self saveContext];           }
                 @catch (NSException *exception) {
                     callback([exception name]);
                 }
             }
             else
             {
                 NSLog(@"WRONG! %@", result);
             }
         }];
    }];
}

- (void)updateTracksCallback:(UpdateDataFail)callback
{
    [self.managedObjectContext performBlockAndWait:^{
        [DCDataProvider
         updateMainDataFromURI:TRACKS_URI
         callBack:^(BOOL success, id result) {
             if (success && result)
             {
                 @try {
                     [self clearTracks];
                     [DCTrack parseFromJsonData:result];
                     [self saveContext];         }
                 @catch (NSException *exception) {
                     callback([exception name]);
                 }
             }
             else
             {
                 NSLog(@"WRONG! %@", result);
             }
         }];
        
    }];
}

- (void)updateLocationCallback:(UpdateDataFail)callback
{
    [self.managedObjectContext performBlockAndWait:^{

        [DCDataProvider
         updateMainDataFromURI:LOCATION_URI
         callBack:^(BOOL success, id result) {
             if (success && result)
             {
                 @try {
                     [self clearLocation];
                     [DCLocation parseFromJsonData:result];
                     [self saveContext];     }
                 @catch (NSException *exception) {
                     callback([exception name]);
                 }
             }
             else
             {
                 NSLog(@"WRONG! %@", result);
             }
         }];
    }];
}

- (NSArray *)executeFetchRequest:(NSFetchRequest *)fetchRequest inContext:(NSManagedObjectContext *)context
{
    @try {
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

- (NSArray*) instancesOfClass:(Class)objectClass filtredUsingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(objectClass) inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setPredicate:predicate];
    return [self executeFetchRequest:fetchRequest inContext:context];
}

- (NSArray *)valuesFromProperties:(NSArray *)values forInstanceOfClass:(Class)objectClass inContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(objectClass) inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:values];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    return [self executeFetchRequest:fetchRequest inContext:context];
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
