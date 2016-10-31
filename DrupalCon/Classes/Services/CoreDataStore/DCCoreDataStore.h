
#import <Foundation/Foundation.h>

@import CoreData;

/**
 *  DCCoreDataStore manages object contexts main and private which has parent
 * main context
 */

@interface DCCoreDataStore : NSObject

+ (instancetype)defaultStore;

/**
 *  Save value from all contexts on disk
 *
 *  @return BOOL if save is success
 */
- (void)saveWithCompletionBlock:(void (^)(BOOL isSuccess))callback;

/**
 *  Save main context on disk
 */

- (void)saveMainContextWithCompletionBlock:(void (^)(BOOL isSuccess))callback;

/**
 *  Context that works on main Queue
 *
 *  @return NSManagedObjectContext which works with NSFetchResultController
 */
+ (NSManagedObjectContext*)mainQueueContext;

/**
 *  Context that works on background Queue
 *
 *  @return  NSManagedObjectContext for backround working
 */
+ (NSManagedObjectContext*)privateQueueContext;

@end
