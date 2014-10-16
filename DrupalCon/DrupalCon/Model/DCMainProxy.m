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
#import "DCBof+DC.h"
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
//TODO: remove import after calendar will be intagrated
#import "AppDelegate.h"
#import "DCLocalNotificationManager.h"
#import "DCLoginViewController.h"
//

#import "DCParseProtocol.h"

const NSString * INVALID_JSON_EXCEPTION = @"Invalid JSON";
static NSString * kDCMainProxyModelName = @"main";

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

#pragma mark - initialization

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

#pragma mark -

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

- (void)updateEvents
{
    [self timeStamp:^(NSString *timeStamp) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        if ([self updateTimeStampSynchronisation:timeStamp])
        {
            UpdateDataFail updateFail = ^(NSString *reason){
                [self setState:DCMainProxyStateLoadingFail];
                @throw [NSException exceptionWithName:@"loading" reason:reason userInfo:nil];
                return;
            };
            
            [self updateClass:[DCType class] withURI:TYPES_URI failCallBack:updateFail];
            [self updateClass:[DCSpeaker class] withURI:SPEKERS_URI failCallBack:updateFail];
            [self updateClass:[DCLevel class] withURI:LEVELS_URI failCallBack:updateFail];
            [self updateClass:[DCTrack class] withURI:TRACKS_URI failCallBack:updateFail];
            [self updateClass:[DCProgram class] withURI:PROGRAMS_URI failCallBack:updateFail];
            [self updateClass:[DCBof class] withURI:BOFS_URI failCallBack:updateFail];
            [self updateClass:[DCLocation class] withURI:LOCATION_URI failCallBack:updateFail];
            [self synchrosizeFavoritePrograms];
            [self loadHtmlAboutInfo:^(NSString *response) {}];
            
            [self setState:DCMainProxyStateDataReady];
            [self saveObject:timeStamp forKey:kTimeStampSynchronisation];
        }
        
        [self dataIsReady];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    }];
}


- (void)dataIsReady
{
    if (self.dataReadyCallback) {
        self.dataReadyCallback(self.state);
    }
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


#pragma mark - getObject for ID

- (NSManagedObject*)getObjectOfClass:(Class)class forID:(NSInteger)ID whereIdKey:(NSString*)idKey
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%@ == %i", idKey, ID];
    NSArray * results = [self instancesOfClass:class
                         filtredUsingPredicate:predicate
                                     inContext:self.managedObjectContext];
    if (results.count > 1)
    {
        @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@",class]
                                       reason:[NSString stringWithFormat:@"too many favorite events for id# %li",ID]
                                     userInfo:nil];
    }
    return (results.count ? [results firstObject] : nil);
}

- (DCFavoriteEvent *)favoriteEventFromID:(NSInteger)eventID
{
    return (DCFavoriteEvent*)[self getObjectOfClass:[DCFavoriteEvent class] forID:eventID whereIdKey:(NSString*)kDCEvent_eventId_key];
}

#pragma mark - Operation with favorites

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
- (void)addToFavoriteEvent:(DCEvent *)event
{
    DCFavoriteEvent *favoriteEvent = [self createFavoriteEvent];
    favoriteEvent.eventID = event.eventID;
    [DCLocalNotificationManager scheduleNotificationWithItem:event interval:10];
    [self saveContext];
}

- (void)removeFavoriteEventWithID:(NSNumber *)eventID
{
    DCFavoriteEvent *favoriteEvent = [self favoriteEventFromID:[eventID integerValue]];
    if (favoriteEvent) {
        [DCLocalNotificationManager cancelLocalNotificationWithId:favoriteEvent.eventID];
        [self removeItem:favoriteEvent inContext:self.managedObjectContext];
    }
    [self saveContext];
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

#pragma mark -

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

#pragma mark - clearing

- (void)removeItem:(NSManagedObject*)item inContext:(NSManagedObjectContext*)context
{
    [context deleteObject:item];
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

#pragma mark - update data

- (void)updateClass:(Class)class withURI:(NSString*)uri failCallBack:(UpdateDataFail)callBack
{
    [self.managedObjectContext performBlockAndWait:^{
        [DCDataProvider updateMainDataFromURI:uri callBack:^(BOOL success, id result) {
            if ([class conformsToProtocol:@protocol(parseProtocol)])
            {
                BOOL success = [class successParceJSONData:result
                                              idsForRemove:nil];
                if (!success)
                {
                    callBack(@"update fail");
                }
            }
            else
            {
                @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@",class]
                                               reason:@"not conform the Parse protocol"
                                             userInfo:nil];
            }
        }];
    }];
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

@end
