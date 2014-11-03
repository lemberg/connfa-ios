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
#import "DCWebService.h"
#import "DCParserService.h"
#import "NSManagedObject+DC.h"
#import "DCCoreDataStore.h"

#import "DCManagedObjectUpdateProtocol.h"

//TODO: remove import after calendar will be intagrated
#import "AppDelegate.h"
#import "DCLocalNotificationManager.h"
#import "DCLoginViewController.h"
//

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

@property (nonatomic, strong) DCWebService *webService;
@property (nonatomic, strong) NSDictionary *classesMap;

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
        sharedProxy = [[self alloc] init];
        [sharedProxy initialise];
    });
    return sharedProxy;
}

// Resources URI are orders according to Core Data update
static NSArray  *RESOURCES_URI;

- (void)initialise
{
    // Initialise web service
    self.webService = [[DCWebService alloc] init];
    
    // Set default data
    [self setState:([self timeStampValue])? DCMainProxyStateDataReady : DCMainProxyStateNoData];
    
    // URI are orders according to Core Data update
    RESOURCES_URI = [NSArray arrayWithObjects:TYPES_URI, SPEKERS_URI,
                     LEVELS_URI, TRACKS_URI,
                     PROGRAMS_URI, BOFS_URI,
                     LOCATION_URI, ABOUT_INFO_URI, nil];
    
}

//  TODO:  Move this methods in separate class call ImportService

#pragma mark - TimeStampValue get/set

// Save time stamp in NSUserDefaults with key [DCMainProxy class]
- (NSInteger)timeStampValue
{
    return [[NSUserDefaults lastUpdateForClass:[DCMainProxy class]] integerValue];
}

- (void)updateTimeStampValue:(NSString *)value
{
    [NSUserDefaults updateTimestampString:value ForClass:[DCMainProxy class]];
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


- (NSDictionary *)classesMap
{
    if  (!_classesMap) {
        _classesMap =  @{ TYPES_URI: [DCType class],
                          SPEKERS_URI: [DCSpeaker class],
                          LEVELS_URI: [DCLevel class],
                          TRACKS_URI: [DCTrack class],
                          PROGRAMS_URI: [DCProgram class],
                          BOFS_URI: [DCBof class],
                          LOCATION_URI: [DCLocation class]
                          };
    }
    return _classesMap;
}


#pragma mark Import data from server


- (void)updateEvents
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //  TODO: Make request to server due to update time stamp and get the response with latest changes
    if (![self timeStampValue]) {
        [self.webService fetchesDataFromURLRequests:[self requestsForUpdateFromURIs:RESOURCES_URI]
                                           callBack:^(BOOL success, NSDictionary *result) {
                                               [self parseData:result withSuccessAction:@selector(updateCoreDataWithDictionary:)];
                                           }];
    } else {
        [self updateSuccess];
    }

}

- (void)updateSuccess
{
    [self setState:DCMainProxyStateDataReady];
    [self dataIsReady];
    //  TODO: Don't update time stamp this way need condition
    [self updateTimeStampValue:@"11111111111"];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)updateFailed
{
    [self rollbackUpdates];
    [self setState:DCMainProxyStateLoadingFail];
    NSLog(@"Update failed");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (NSArray *)requestsForUpdateFromURIs:(NSArray *)uris
{
    NSMutableArray *requestsPlaceHolder = [NSMutableArray array];
    for (NSString *uri in uris) {
        NSURLRequest *request = [DCWebService urlRequestForURI:uri
                                                withHTTPMethod:@"GET"
                                             withHeaderOptions:nil];
        [requestsPlaceHolder addObject:request];
    }
    return requestsPlaceHolder;
}


- (void)updateCoreDataWithDictionary:(NSDictionary *)newDict
{
    NSDictionary *dict = newDict;
    
    // TODO: Create model for this information, now I don't know what todo
    [NSUserDefaults saveAbout:dict[ABOUT_INFO_URI][kAboutInfo]];
    
    // Update core data
    NSManagedObjectContext *backgroundContext =  [DCCoreDataStore privateQueueContext];
    [backgroundContext  performBlock:^{
        [self fillInModelsFromDictionary:dict inContext:backgroundContext];
        if ([[DCCoreDataStore defaultStore] save]) {
            [self updateSuccess];
        } else {
            [self updateFailed];
        }

    }];

}


- (void)fillInModelsFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    //  FIXME: Remove hard code because this URI resources will come from server repsonse
    for (NSString *keyUri in RESOURCES_URI) {
        // Get class map to URI
        Class model = self.classesMap[keyUri];
        // Check is model can update with dictionary
        if ([model conformsToProtocol:@protocol(ManagedObjectUpdateProtocol)]) {
            [model updateFromDictionary:dict[keyUri] inContext:context];
        } else if (model) {
            NSAssert(NO, @"Model cann't be updated because it doesn't have ManagedObjectUpdateProtocol");
        }
    }
    
}


- (void)parseData:(NSDictionary *)data withSuccessAction:(SEL)successSelector
{
    DCParserService *parserService = [[DCParserService alloc] init];
    [parserService  parseJSONDataFromDictionary:data
                                   withCallBack:[self parseCallBackWithSuccessAction:successSelector]];
}

- (CompleteParseCallback)parseCallBackWithSuccessAction:(SEL)successSelector;
{
    CompleteParseCallback callback = ^(NSError *error, NSDictionary *result) {
        if (!error) {
            [self performSelectorOnMainThread:successSelector withObject:result waitUntilDone:NO];
        } else {
            NSLog(@"Parse failed");
            [self updateFailed];
        }
        
    };
    return callback;
}

- (void)dataIsReady
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.dataReadyCallback) {
            self.dataReadyCallback(self.state);
        }
    });

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
    return [self instancesOfClass:aClass filtredUsingPredicate:nil inContext:self.newMainQueueContext];
}

- (NSManagedObject*)objectForID:(int)ID ofClass:(Class)aClass inContext:(NSManagedObjectContext *)context
{
    if ([aClass conformsToProtocol:@protocol(ManagedObjectUpdateProtocol)]) {
        return [self getObjectOfClass:aClass forID:ID whereIdKey:[aClass idKey] inContext:context];
    }
    else
    {
        @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@",NSStringFromClass(aClass)]
                                       reason:@"Do not conform protocol"
                                     userInfo:nil];
        return nil;
    }
}


#pragma mark -

- (NSManagedObject*)getObjectOfClass:(Class)class forID:(NSInteger)ID whereIdKey:(NSString*)idKey inContext:(NSManagedObjectContext *)context
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%@ == %i", idKey, ID];
    NSArray * results = [self instancesOfClass:class
                         filtredUsingPredicate:predicate
                                     inContext:context];
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
    DCFavoriteEvent *favoriteEvent = [DCFavoriteEvent createManagedObjectInContext:self.newMainQueueContext];//(DCFavoriteEvent*)[self createObjectOfClass:[DCFavoriteEvent class]];
    favoriteEvent.eventID = event.eventID;
    [DCLocalNotificationManager scheduleNotificationWithItem:event interval:10];
    [self saveContext];
}

- (void)removeFavoriteEventWithID:(NSNumber *)eventID
{
    DCFavoriteEvent *favoriteEvent = (DCFavoriteEvent*)[self objectForID:[eventID intValue]
                                                                 ofClass:[DCFavoriteEvent class]
                                                               inContext:self.defaultPrivateContext];
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

- (void)loadHtmlAboutInfo:(void(^)(NSString *))callback
{
    callback([NSUserDefaults aboutString]);
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




#pragma mark - Core Data stack


- (NSManagedObjectContext*)defaultPrivateContext
{

    return [DCCoreDataStore privateQueueContext];
}

-(NSManagedObjectContext*)newMainQueueContext
{

    return [DCCoreDataStore mainQueueContext];
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
