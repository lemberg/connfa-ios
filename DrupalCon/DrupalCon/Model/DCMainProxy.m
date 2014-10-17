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
#import "NSUserDefaults+DC.h"

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
workContext=_workContext,
defaultPrivateContext=_defaultPrivateContext,
persistentStoreCoordinator=_persistentStoreCoordinator;

#pragma mark - initialization

+ (DCMainProxy*)sharedProxy
{
    static id sharedProxy = nil;
    static dispatch_once_t disp;
    dispatch_once(&disp, ^{
        sharedProxy = [[super alloc] init];
        [sharedProxy setState:([(NSString*)[NSUserDefaults lastUpdateForClass:[DCType class]] integerValue]!=0?DCMainProxyStateDataReady:DCMainProxyStateNoData)];
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
    _workContext = [self newMainQueueContext];
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    UpdateDataFail updateFail = ^(NSString *reason){
        [self setState:DCMainProxyStateLoadingFail];
        @throw [NSException exceptionWithName:@"loading" reason:reason userInfo:nil];
        return;
    };
    
    NSString * typesLastModified = [self updateClass:[DCType class] withURI:TYPES_URI failCallBack:updateFail];
    NSString * speakersLastModified = [self updateClass:[DCSpeaker class] withURI:SPEKERS_URI failCallBack:updateFail];
    NSString * levelsLastModified = [self updateClass:[DCLevel class] withURI:LEVELS_URI failCallBack:updateFail];
    NSString * tracksLastModified = [self updateClass:[DCTrack class] withURI:TRACKS_URI failCallBack:updateFail];
    NSString * programsLastModified = [self updateClass:[DCProgram class] withURI:PROGRAMS_URI failCallBack:updateFail];
    NSString * bofsLastModified = [self updateClass:[DCBof class] withURI:BOFS_URI failCallBack:updateFail];
    NSString * locationsLastModified = [self updateClass:[DCLocation class] withURI:LOCATION_URI failCallBack:updateFail];
    [self loadHtmlAboutInfo:^(NSString *response) {}];
    
    if (self.state != DCMainProxyStateLoadingFail) {
        [self setState:DCMainProxyStateDataReady];
        [self saveContext];
        _workContext = [self newMainQueueContext];
        
        [NSUserDefaults updateTimestampString:typesLastModified ForClass:[DCType class]];
        [NSUserDefaults updateTimestampString:speakersLastModified ForClass:[DCSpeaker class]];
        [NSUserDefaults updateTimestampString:levelsLastModified ForClass:[DCLevel class]];
        [NSUserDefaults updateTimestampString:tracksLastModified ForClass:[DCTrack class]];
        [NSUserDefaults updateTimestampString:programsLastModified ForClass:[DCProgram class]];
        [NSUserDefaults updateTimestampString:bofsLastModified ForClass:[DCBof class]];
        [NSUserDefaults updateTimestampString:locationsLastModified ForClass:[DCLocation class]];
        
        [self dataIsReady];
    }
    else
    {
        [self rollbackUpdates];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)dataIsReady
{
    if (self.dataReadyCallback) {
        self.dataReadyCallback(self.state);
    }
}

#pragma mark - getting instances

- (NSArray *)eventsWithIDs:(NSArray *)iDs
#warning this method used by LocalNotification process. Can be obsolated
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"eventID IN %@", iDs];
    NSArray *results = [self instancesOfClass:[DCEvent class]
                         filtredUsingPredicate:predicate
                                     inContext:self.defaultPrivateContext];
    return results;
}

- (NSArray*)getAllInstancesOfClass:(Class)aClass inMainQueue:(BOOL)mainQueue
{
    return [self instancesOfClass:aClass filtredUsingPredicate:nil inContext:(mainQueue?self.workContext:self.defaultPrivateContext)];
}

- (NSManagedObject*)objectForID:(int)ID ofClass:(Class)aClass inMainQueue:(BOOL)mainQueue
{
    if ([aClass conformsToProtocol:@protocol(parseProtocol)]) {
        return [self getObjectOfClass:aClass forID:ID whereIdKey:[aClass idKey] inMainQueue:mainQueue];
    }
    else
    {
        @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@",NSStringFromClass(aClass)]
                                       reason:@"Do not conform protocol"
                                     userInfo:nil];
        return nil;
    }
}

- (NSManagedObject*)createObjectOfClass:(Class)aClass
{
    return [self createInstanceOfClass:aClass inContext:self.defaultPrivateContext];
}

#pragma mark -

- (NSManagedObject*)getObjectOfClass:(Class)class forID:(NSInteger)ID whereIdKey:(NSString*)idKey inMainQueue:(BOOL)mainQueue
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%@ == %i", idKey, ID];
    NSArray * results = [self instancesOfClass:class
                         filtredUsingPredicate:predicate
                                     inContext:(mainQueue?self.workContext:self.defaultPrivateContext)];
    if (results.count > 1)
    {
        @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@",class]
                                       reason:[NSString stringWithFormat:@"too many objects id# %li",ID]
                                     userInfo:nil];
    }
    return (results.count ? [results firstObject] : nil);
}



#pragma mark - Operation with favorites

- (void)addToFavoriteEvent:(DCEvent *)event
{
    DCFavoriteEvent *favoriteEvent = (DCFavoriteEvent*)[self createObjectOfClass:[DCFavoriteEvent class]];
    favoriteEvent.eventID = event.eventID;
    [DCLocalNotificationManager scheduleNotificationWithItem:event interval:10];
    [self saveContext];
}

- (void)removeFavoriteEventWithID:(NSNumber *)eventID
{
    DCFavoriteEvent *favoriteEvent = (DCFavoriteEvent*)[self objectForID:[eventID intValue] ofClass:[DCFavoriteEvent class] inMainQueue:NO];
    if (favoriteEvent) {
        [DCLocalNotificationManager cancelLocalNotificationWithId:favoriteEvent.eventID];
        [self removeItem:favoriteEvent];
    }
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
    [self.defaultPrivateContext performBlockAndWait:^{
        [DCDataProvider updateMainDataFromURI:ABOUT_INFO_URI lastModified:@"" callBack:^(BOOL success, id result, id lastModifiedResponce) {
            if (success && result && lastModifiedResponce)
            {
                NSError *error;
                NSDictionary * about  = [NSJSONSerialization JSONObjectWithData:result
                                                                        options:kNilOptions
                                                                          error:&error];
                [NSUserDefaults saveAbout:[about objectForKey:kAboutInfo]];
                callback([NSUserDefaults aboutString]);
            }
            else
            {
                if ([NSUserDefaults aboutString])
                {
                    callback([NSUserDefaults aboutString]);
                }
                else
                {
                    callback(@"");
                }
                
                NSLog(@"WRONG! %@", result);
            }
        }];
    }];
}

#pragma mark - DO save/not save/delete

- (void)saveContext
{
    NSError * err = nil;
    [self.defaultPrivateContext save:&err];
    if (err)
    {
        NSLog(@"WRONG! context save");
    }
}

- (void)removeItem:(NSManagedObject*)item
{
    [self.defaultPrivateContext deleteObject:item];
}

- (void)rollbackUpdates
{
    [self.defaultPrivateContext rollback];
}

#pragma mark - update data

// returns new last-modified timestamp
- (NSString*)updateClass:(Class)class withURI:(NSString*)uri failCallBack:(UpdateDataFail)callBack
{
    if ([class conformsToProtocol:@protocol(parseProtocol)])
    {
        __block NSString * lastModifiedResult = nil;
        [self.defaultPrivateContext performBlockAndWait:^{
            [DCDataProvider updateMainDataFromURI:uri lastModified:[NSUserDefaults lastUpdateForClass:class] callBack:^(BOOL success, id result, id lastModifiedResponce) {
                
                if (!success)
                {
                    callBack(@"update fail");
                }
                
                //PARSING ...
                BOOL successParse = [class successParceJSONData:result];
                if (successParse && lastModifiedResult)
                {
                    lastModifiedResult = (NSString*)lastModifiedResponce;
                }
                else if (!successParse)
                {
                    callBack(@"parse fail");
                }
                
                // ELSE: no change, no need to parse

            }];
        }];
        return lastModifiedResult;
    }
    else
    {
        @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@",class]
                                       reason:@"not conform the parse protocol"
                                     userInfo:nil];
    }
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

- (NSManagedObjectContext*)defaultPrivateContext
{
    if (!_defaultPrivateContext)
    {
        NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
        if (coordinator)
        {
            _defaultPrivateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_defaultPrivateContext setPersistentStoreCoordinator:coordinator];
        }
        
    }
    return _defaultPrivateContext;
}

-(NSManagedObjectContext*)newMainQueueContext
{
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    context.parentContext = self.defaultPrivateContext;
    return context;
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
