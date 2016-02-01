
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString* INVALID_JSON_EXCEPTION;

@class DCMainEvent, DCBof, DCType, DCTime, DCTimeRange, DCSpeaker, DCLevel,
    DCTrack, DCLocation, DCEvent;

typedef enum {
  DCMainProxyStateNone = 0,
  DCMainProxyStateNoData,
  DCMainProxyStateLoadingFail,
  DCMainProxyStateInitDataLoading,
  DCMainProxyStateDataLoading,
  DCMainProxyStateUpdatesWaiting,
  DCMainProxyStateDataReady,
  DCmainProxyStateDataNotChange,
  DCMainProxyStateDataUpdated
} DCMainProxyState;

@interface DCMainProxy : NSObject

@property(nonatomic, strong, readonly)
    NSManagedObjectContext* defaultPrivateContext;
@property(nonatomic, strong, readonly) NSManagedObjectContext* workContext;
@property(nonatomic, strong, readonly) NSManagedObjectModel* managedObjectModel;
@property(nonatomic, strong, readonly)
    NSPersistentStoreCoordinator* persistentStoreCoordinator;

@property(nonatomic) DCMainProxyState state;

+ (DCMainProxy*)sharedProxy;
- (NSManagedObjectContext*)newMainQueueContext;
- (void)setDataReadyCallback:
    (void (^)(DCMainProxyState mainProxyState))dataReadyCallback;
- (void)setDataUpdatedCallback:
    (void (^)(DCMainProxyState mainProxyState))dataUpdatedCallback;

#pragma mark - public

- (void)update;
- (BOOL)checkReachable;
- (NSTimeZone *)isSystemTimeCoincidencWithEventTimezone;

#pragma mark - work with instances
- (NSTimeZone*)eventTimeZone;

- (NSArray*)getAllInstancesOfClass:(Class)aClass inMainQueue:(BOOL)mainQueue;
- (NSArray*)getAllInstancesOfClass:(Class)aClass
                         predicate:(NSPredicate*)aPredicate
                       inMainQueue:(BOOL)mainQueue;
- (NSManagedObject*)objectForID:(int)ID
                        ofClass:(Class)aClass
                      inContext:(NSManagedObjectContext*)context;
- (void)removeItem:(NSManagedObject*)item;
- (NSArray*)getAllInstancesOfClass:(Class)aClass
                         inContext:(NSManagedObjectContext*)context;

#pragma mark -

- (void)loadHtmlAboutInfo:(void (^)(NSString*))callback;

#pragma mark - favorites

// FIXME: separate Favorites to favoriteManager

- (void)addToFavoriteEvent:(DCEvent*)event;
- (void)removeFavoriteEventWithID:(DCEvent*)event;
- (NSArray*)eventsWithIDs:(NSArray*)iDs;
- (void)openLocalNotification:(UILocalNotification*)localNotification;

@end
