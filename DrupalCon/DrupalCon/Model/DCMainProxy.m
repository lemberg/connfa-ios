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
#import "DCLocalNotificationManager.h"
#import "DCLoginViewController.h"

const NSString * INVALID_JSON_EXCEPTION = @"Invalid JSON";
static NSString * kDCMainProxyModelName = @"main";

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

#pragma mark - block declaration

typedef void(^UpdateDataFail)(NSString *reason);

#pragma mark -

@interface DCMainProxy ()

@property (nonatomic, copy) void(^dataReadyCallback)(DCMainProxyState mainProxyState);

@end

#pragma mark -
#pragma mark -

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
        [sharedProxy setState:([sharedProxy savedValueForKey:kTimeStampSynchronisation]?DCMainProxyStateDataReady:DCMainProxyStateNoData)];
    });
    return sharedProxy;
}

- (void)setDataReadyCallback:(void (^)(DCMainProxyState))dataReadyCallback
{
    if (self.state == DCMainProxyStateDataReady)
    {
        dataReadyCallback(self.state);
    }
    
    _dataReadyCallback = dataReadyCallback;
}

- (void)startNetworkChecking
{
//    Reachability * reach = [Reachability reachabilityWithHostname:SERVER_URL];
    Reachability * reach = [Reachability reachabilityWithHostname:@"google.com"];
    if (reach.isReachable)
    {
        [self updateEvents];
    }
    else
    {
        if (self.state == DCMainProxyStateInitDataLoading)
        {
            [self setState:DCMainProxyStateNoData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Attention"
                                            message:@"Internet connection is not available at this moment. Please, try later"
                                           delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil] show];
            });
        }
        else
        {
            [self setState:DCMainProxyStateLoadingFail];
            [self dataIsReady];
        }
    }
    return;
}

#pragma mark - public

- (void)update
{
    if (self.state == DCMainProxyStateInitDataLoading ||
        self.state == DCMainProxyStateDataLoading)
    {
        NSLog(@"data is already in loading progress");
        return;
    }
    else if (self.state == DCMainProxyStateNoData)
    {
        [self setState:DCMainProxyStateInitDataLoading];
    }
    else
    {
        [self setState:DCMainProxyStateDataLoading];
    }
    
    [self startNetworkChecking];
}

- (void)dataIsReady
{
    if (self.dataReadyCallback) {
        self.dataReadyCallback(self.state);
    }
}

- (void)updateEvents
{
    // FIXME: Create director pattern to observe and handle synchronisation proccess

    [self timeStamp:^(NSString *timeStamp) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        if ([self updateTimeStampSynchronisation:timeStamp])
        {
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
            [self loadHtmlAboutInfo:^(NSString *response) {}];
            
            if (!isUpdateFail)
            {
                [self setState:DCMainProxyStateDataReady];
                [self saveObject:timeStamp forKey:kTimeStampSynchronisation];
            }
            else
            {
                [self setState:DCMainProxyStateLoadingFail];
            }
        }
        
        [self dataIsReady];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    }];
}

- (void)openLocalNotification:(UILocalNotification *)localNotification
{
// FIXME: Rewrite this code. It create stack with favorite controller and event detail controller.
    UINavigationController *navigation = (UINavigationController *)[(AppDelegate*)[[UIApplication sharedApplication] delegate] window].rootViewController;
    [navigation popToRootViewControllerAnimated:NO];
    NSNumber *eventID = localNotification.userInfo[@"EventID"];
    NSArray *event = [[DCMainProxy sharedProxy] eventsWithIDs:@[eventID]];
    [(DCLoginViewController *)[navigation topViewController] openEventFromFavoriteController:[event firstObject]];
    
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
             NSDictionary * stamp = [NSJSONSerialization JSONObjectWithData:result
                                                                     options:kNilOptions
                                                                       error:&err];
             callback([stamp objectForKey:kTimeStampSynchronisation]);
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
    NSArray *events = [self eventsWithIDs:favorteIDs];
    for (DCEvent *program in events) {
        program.favorite = [NSNumber numberWithBool:YES];
    }
    [self saveContext];
    
}

- (NSArray *)eventsWithIDs:(NSArray *)iDs
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"eventID IN %@", iDs];
    NSArray *results = [self instancesOfClass:[DCEvent class]
                         filtredUsingPredicate:predicate
                                     inContext:self.managedObjectContext];
    return results;
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

- (void)addToFavoriteEvent:(DCEvent *)event
{
    DCFavoriteEvent *favoriteEvent = [self createFavoriteEvent];
    favoriteEvent.eventID = event.eventID;
    [DCLocalNotificationManager scheduleNotificationWithItem:event interval:10];
    [self saveContext];
}

- (void)removeFavoriteEventWithID:(NSNumber *)eventID
{
    DCFavoriteEvent *event = [self favoriteEventFromID:[eventID integerValue]];
    if (event) {
        [DCLocalNotificationManager cancelLocalNotificationWithId:event.eventID];
        [self removeItems:@[event]
                inContext:self.managedObjectContext];
        
    }
    [self saveContext];
}

- (void)loadHtmlAboutInfo:(void(^)(NSString *))callback
{
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
