
#import "DCMainProxy.h"
#import "DCEvent+DC.h"
#import "DCMainEvent+DC.h"
#import "DCBof+DC.h"
#import "DCType+DC.h"
#import "DCTime+DC.h"
#import "DCTimeRange+DC.h"
#import "DCSpeaker+DC.h"
#import "DCLevel+DC.h"
#import "DCTrack+DC.h"
#import "DCLocation+DC.h"

#import "NSDate+DC.h"
#import "NSUserDefaults+DC.h"

#import "Reachability.h"
#import "DCWebService.h"
#import "DCParserService.h"
#import "NSManagedObject+DC.h"
#import "DCCoreDataStore.h"
#import "DCAppSettings.h"

#import "DCManagedObjectUpdateProtocol.h"

// TODO: remove import after calendar will be intagrated
#import "AppDelegate.h"
#import "DCLoginViewController.h"
#import "DCMainNavigationController.h"
//

#import "DCImportDataSevice.h"
#import "DCCalendarManager.h"
#import "DCAlertsManager.h"

const NSString* INVALID_JSON_EXCEPTION = @"Invalid JSON";

#pragma mark - block declaration

typedef void (^UpdateDataFail)(NSString* reason);

#pragma mark -

@interface DCMainProxy ()<DCImportDataSeviceDelegate>

@property(nonatomic, copy) __block void (^dataReadyCallback)
    (DCMainProxyState mainProxyState);

@property(nonatomic, copy) __block void (^dataUpdatedCallback)
  (DCMainProxyState mainProxyState);
//
@property(strong, nonatomic) DCImportDataSevice* importDataService;

@property(nonatomic) NSTimeZone* applicationTimeZone;

@property(nonatomic) DCCalendarManager* calendarManager;
@end

#pragma mark -
#pragma mark -

@implementation DCMainProxy

@synthesize managedObjectModel = _managedObjectModel,
            workContext = _workContext,
            defaultPrivateContext = _defaultPrivateContext,
            persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - initialization

+ (DCMainProxy*)sharedProxy {
  static id sharedProxy = nil;
  static dispatch_once_t disp;
  dispatch_once(&disp, ^{
    sharedProxy = [[self alloc] init];

    [sharedProxy initialise];
  });
  return sharedProxy;
}

- (void)initialise {
  // Initialise import data service

  self.importDataService = [[DCImportDataSevice alloc]
      initWithManagedObjectContext:[DCCoreDataStore defaultStore]
                       andDelegate:self];
  // Set default data
  [self setState:(![self.importDataService isInitDataImport])
                     ? DCMainProxyStateDataReady
                     : DCMainProxyStateNoData];
  self.calendarManager = [[DCCalendarManager alloc] init];
}

- (NSTimeZone*)eventTimeZone {
  if (!self.applicationTimeZone) {
    NSArray* settings = [[DCMainProxy sharedProxy]
        getAllInstancesOfClass:[DCAppSettings class]
                     inContext:[self defaultPrivateContext]];
    DCAppSettings* appSetting = [settings lastObject];
    self.applicationTimeZone = [NSTimeZone timeZoneWithName:appSetting.timeZoneName];
  }
  return self.applicationTimeZone;
}

- (NSTimeZone *)isSystemTimeCoincidencWithEventTimezone {
  NSTimeZone *eventTimeZone = [self eventTimeZone];
  NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
  if (eventTimeZone.secondsFromGMT == systemTimeZone.secondsFromGMT) {
    return nil;
  }
  return eventTimeZone;
}

- (void)setDataReadyCallback:(void (^)(DCMainProxyState))dataReadyCallback {
  if (self.state == DCMainProxyStateDataReady ||
      self.state == DCmainProxyStateDataNotChange ||
      self.state == DCMainProxyStateDataUpdated) {
    if (dataReadyCallback) {
      dataReadyCallback(self.state);
    }
  }

  _dataReadyCallback = dataReadyCallback;
}

- (void)setDataUpdatedCallback:(void (^)(DCMainProxyState))dataUpdatedCallback {
  _dataUpdatedCallback = dataUpdatedCallback;
}

#pragma mark - public

- (void)update {
  if (!_workContext) {
    _workContext = [self newMainQueueContext];
  }

  if (self.state == DCMainProxyStateInitDataLoading ||
      self.state == DCMainProxyStateDataLoading) {
    NSLog(@"data is already in loading progress");
    return;
  } else {
    if ([self checkReachable]) {
      if (self.state == DCMainProxyStateNoData) {
        [self setState:DCMainProxyStateInitDataLoading];
      } else {
        [self setState:DCMainProxyStateDataLoading];
      }

      [self updateEvents];
    } else {
      if ([self.importDataService isInitDataImport]) {
        dispatch_async(dispatch_get_main_queue(), ^{

          [DCAlertsManager showAlertWithTitle:@"Attention"
                                      message:@"Internet connection is not available at this moment. Please, try later"];
        });
      }
    }
  }
}

#pragma mark -

- (BOOL)checkReachable {
  Reachability* reach = [Reachability reachabilityWithHostname:@"google.com"];
  return reach.isReachable;
}

#pragma mark Import data from server

- (void)updateEvents {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  //  Import data from the external storage

  [self.importDataService chechUpdates];
}

#pragma mark
- (void)importDataServiceFinishedImport:(DCImportDataSevice*)importDataService
                             withStatus:(DCImportDataSeviceImportStatus)status {
  switch (status) {
    case DCDataUpdateFailed: {
      [self setState:DCMainProxyStateLoadingFail];
      NSLog(@"Update failed");
      break;
    }
    case DCDataNotChanged: {
      [self setState:DCmainProxyStateDataNotChange];
      [self dataIsReady];

      break;
    }
    case DCDataUpdateSuccess: {
      [self setState:DCMainProxyStateDataUpdated];
      [self dataIsReady];
      break;
    }

    default:
      break;
  }
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)dataIsReady {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.dataReadyCallback) {
      self.dataReadyCallback(self.state);
    }
  });
  
  if (self.state == DCMainProxyStateDataUpdated) {
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if (self.dataUpdatedCallback) {
        self.dataUpdatedCallback(self.state);
      }
    });
  }
  
}

#pragma mark - getting instances

- (NSArray*)eventsWithIDs:(NSArray*)iDs
#warning this method used by LocalNotification process. Can be obsolated
{
  NSPredicate* predicate =
      [NSPredicate predicateWithFormat:@"%K IN %@", kDCEventIdKey, iDs];
  NSArray* results = [self instancesOfClass:[DCEvent class]
                      filtredUsingPredicate:predicate
                                  inContext:self.defaultPrivateContext];
  return results;
}

- (NSArray*)getAllInstancesOfClass:(Class)aClass inMainQueue:(BOOL)mainQueue {
  return
      [self getAllInstancesOfClass:aClass predicate:nil inMainQueue:mainQueue];
}

- (NSArray*)getAllInstancesOfClass:(Class)aClass
                         inContext:(NSManagedObjectContext*)context {
  return [self instancesOfClass:aClass
          filtredUsingPredicate:nil
                      inContext:context];
}

- (NSArray*)getAllInstancesOfClass:(Class)aClass
                         predicate:(NSPredicate*)aPredicate
                       inMainQueue:(BOOL)mainQueue {
  return [self instancesOfClass:aClass
          filtredUsingPredicate:aPredicate
                      inContext:self.newMainQueueContext];
}

- (NSManagedObject*)objectForID:(int)ID
                        ofClass:(Class)aClass
                      inContext:(NSManagedObjectContext*)context {
  if ([aClass conformsToProtocol:@protocol(ManagedObjectUpdateProtocol)]) {
    return [self getObjectOfClass:aClass
                            forID:ID
                       whereIdKey:[aClass idKey]
                        inContext:context];
  } else {
    @throw [NSException
        exceptionWithName:[NSString
                              stringWithFormat:@"%@", NSStringFromClass(aClass)]
                   reason:@"Do not conform protocol"
                 userInfo:nil];
    return nil;
  }
}

#pragma mark -

- (NSManagedObject*)getObjectOfClass:(Class) class
                               forID:(NSInteger)ID
                          whereIdKey:(NSString*)idKey
                           inContext:(NSManagedObjectContext*)context {
  NSPredicate* predicate =
      [NSPredicate predicateWithFormat:@"%K = %i", idKey, ID];
  NSArray* results = [self instancesOfClass:class
                      filtredUsingPredicate:predicate
                                  inContext:context];
  if (results.count > 1) {
    @throw [NSException
        exceptionWithName:[NSString stringWithFormat:@"%@", class]
                   reason:[NSString
                              stringWithFormat:@"too many objects id# %li", ID]
                 userInfo:nil];
  }
  return (results.count ? [results firstObject] : nil);
}
#pragma mark - Operation with favorites

    - (void)addToFavoriteEvent : (DCEvent*)event {
  event.favorite = [NSNumber numberWithBool:YES];
  [[DCCoreDataStore defaultStore] saveWithCompletionBlock:nil];

  [self.calendarManager addEventWithItem:event interval:5];
}

- (void)removeFavoriteEventWithID:(DCEvent*)event {
  event.favorite = [NSNumber numberWithBool:NO];
  [[DCCoreDataStore defaultStore] saveWithCompletionBlock:nil];

  [self.calendarManager removeEventOfItem:event];
}

- (void)openLocalNotification:(UILocalNotification*)localNotification {
  // FIXME: Rewrite this code. It create stack with favorite controller and
  // event detail controller.
  DCMainNavigationController* navigation =
      (DCMainNavigationController*)
          [(AppDelegate*)[[UIApplication sharedApplication] delegate] window]
              .rootViewController;

  [navigation popToRootViewControllerAnimated:NO];

  NSNumber* eventID = localNotification.userInfo[@"EventID"];
  NSArray* event = [[DCMainProxy sharedProxy] eventsWithIDs:@[ eventID ]];

  if ([navigation
          respondsToSelector:@selector(openEventFromFavoriteController:)]) {
    [navigation openEventFromFavoriteController:[event firstObject]];
  }
}

- (void)loadHtmlAboutInfo:(void (^)(NSString*))callback {
  callback([NSUserDefaults aboutString]);
}

#pragma mark - DO save/not save/delete

- (void)saveContext {
  NSError* err = nil;
  [self.defaultPrivateContext save:&err];
  if (err) {
    NSLog(@"WRONG! context save");
  }
}

- (void)removeItem:(NSManagedObject*)item {
  [self.defaultPrivateContext deleteObject:item];
}

- (void)rollbackUpdates {
  [self.defaultPrivateContext rollback];
}

#pragma mark - Core Data stack

- (NSManagedObjectContext*)defaultPrivateContext {
  return [DCCoreDataStore privateQueueContext];
}

- (NSManagedObjectContext*)newMainQueueContext {
  return [DCCoreDataStore mainQueueContext];
}

#pragma mark -

- (NSArray*)executeFetchRequest:(NSFetchRequest*)fetchRequest
                      inContext:(NSManagedObjectContext*)context {
  @try {
    NSArray* result = [context executeFetchRequest:fetchRequest error:nil];
    if (result && [result count]) {
      return result;
    }
  } @catch (NSException* exception) {
    NSLog(@"%@", NSStringFromClass([self class]));
    NSLog(@"%@", [context description]);
    NSLog(@"%@", [context.persistentStoreCoordinator description]);
    NSLog(@"%@",
          [context.persistentStoreCoordinator.managedObjectModel description]);
    NSLog(@"%@", [context.persistentStoreCoordinator.managedObjectModel
                         .entities description]);
    @throw exception;
  } @finally {
  }
  return nil;
}

- (NSArray*)instancesOfClass:(Class)objectClass
       filtredUsingPredicate:(NSPredicate*)predicate
                   inContext:(NSManagedObjectContext*)context {
  NSEntityDescription* entityDescription =
      [NSEntityDescription entityForName:NSStringFromClass(objectClass)
                  inManagedObjectContext:context];
  NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
  [fetchRequest setEntity:entityDescription];
  [fetchRequest setReturnsObjectsAsFaults:NO];
  [fetchRequest setPredicate:predicate];
  return [self executeFetchRequest:fetchRequest inContext:context];
}

- (NSArray*)valuesFromProperties:(NSArray*)values
              forInstanceOfClass:(Class)objectClass
                       inContext:(NSManagedObjectContext*)context {
  NSEntityDescription* entityDescription =
      [NSEntityDescription entityForName:NSStringFromClass(objectClass)
                  inManagedObjectContext:context];
  NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
  [fetchRequest setEntity:entityDescription];
  [fetchRequest setResultType:NSDictionaryResultType];
  [fetchRequest setPropertiesToFetch:values];
  [fetchRequest setReturnsObjectsAsFaults:NO];
  return [self executeFetchRequest:fetchRequest inContext:context];
}

- (id)createInstanceOfClass:(Class)instanceClass
                  inContext:(NSManagedObjectContext*)context {
  NSEntityDescription* entityDescription =
      [NSEntityDescription entityForName:NSStringFromClass(instanceClass)
                  inManagedObjectContext:context];
  NSManagedObject* result =
      [[NSManagedObject alloc] initWithEntity:entityDescription
               insertIntoManagedObjectContext:context];
  return result;
}

@end
