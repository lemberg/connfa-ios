
#import <Foundation/Foundation.h>
#import "DCCoreDataStore.h"

@protocol DCImportDataSeviceDelegate;

typedef enum {
  DCDataNotChanged = 0,
  DCDataUpdateFailed,
  DCDataUpdateSuccess

} DCImportDataSeviceImportStatus;

/**
 *  Import data data from web service and save on disk
 */

@interface DCImportDataSevice : NSObject

@property(weak, nonatomic) DCCoreDataStore* coreDataStore;
@property(weak, nonatomic) id<DCImportDataSeviceDelegate> delegate;

// Insert and update data in current context,
- (instancetype)initWithManagedObjectContext:(DCCoreDataStore*)coreDataStore
                                 andDelegate:
                                     (id<DCImportDataSeviceDelegate>)delegate;
- (void)chechUpdates;
- (BOOL)isInitDataImport;

@end

@protocol DCImportDataSeviceDelegate<NSObject>

- (void)importDataServiceFinishedImport:(DCImportDataSevice*)importDataService
                             withStatus:(DCImportDataSeviceImportStatus)status;

@end
