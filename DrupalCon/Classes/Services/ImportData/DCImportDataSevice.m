
#import "DCImportDataSevice.h"

#import "DCMainProxy.h"
#import "DCEvent+DC.h"
#import "DCMainEvent+DC.h"
#import "DCBof+DC.h"
#import "DCSocialEvent+DC.h"
#import "DCType+DC.h"
#import "DCTime+DC.h"
#import "DCTimeRange+DC.h"
#import "DCSpeaker+DC.h"
#import "DCLevel+DC.h"
#import "DCTrack+DC.h"
#import "DCLocation+DC.h"
#import "DCHousePlan+DC.h"
#import "DCPoi+DC.h"
#import "DCInfo+DC.h"
#import "DCTwitter+DC.h"
#import "DCAppSettings+DC.h"

#import "DCWebService.h"
#import "DCParserService.h"

#import "NSUserDefaults+DC.h"

static NSString* const CHECK_UPDATES_URI = @"checkUpdates";
static NSString* const IDS_FOR_UPDATE = @"idsForUpdate";
static NSString* const TYPES_URI = @"getTypes";
static NSString* const LEVELS_URI = @"getLevels";
static NSString* const TRACKS_URI = @"getTracks";
static NSString* const SPEAKERS_URI = @"getSpeakers";
static NSString* const LOCATIONS_URI = @"getLocations";
static NSString* const HOUSEPLANS_URI = @"getHousePlans";
static NSString* const SESSIONS_URI = @"getSessions";
static NSString* const BOFS_URI = @"getBofs";
static NSString* const SOCIAL_EVENTS_URI = @"getSocialEvents";
static NSString* const POI_URI = @"getPOI";
static NSString* const INFO_URI = @"getInfo";
static NSString* const TWITTER_URI = @"getTwitter";
static NSString* const SETTINGS_URI = @"getSettings";

@interface DCImportDataSevice ()

@property(nonatomic, strong) DCWebService* webService;
@property(nonatomic, strong) NSDictionary* classesMap;
@property(nonatomic, strong) NSArray* resourceURIs;

// buffer parameter for Last-Modified, stored after transaction finish
// successfuly
@property(nonatomic, strong) NSString* preLastModified;

@end

@implementation DCImportDataSevice

- (instancetype)initWithManagedObjectContext:(DCCoreDataStore*)coreDataStore
                                 andDelegate:
                                     (id<DCImportDataSeviceDelegate>)delegate {
  self = [super init];
  if (self) {
    self.coreDataStore = coreDataStore;
    self.delegate = delegate;
    // Initialise web service
    self.webService = [[DCWebService alloc] init];
  }
  return self;
}

- (BOOL)isInitDataImport {
  NSString* timestamp = [self timeStampValue];

  return [self isStringEmpty:timestamp];
}

- (BOOL)isStringEmpty:(NSString*)string {
  return !string || [string length] == 0;
}

- (NSDictionary*)classesMap {
  if (!_classesMap) {
    _classesMap = @{
      TYPES_URI : [DCType class],
      SETTINGS_URI : [DCAppSettings class],
      SPEAKERS_URI : [DCSpeaker class],
      LEVELS_URI : [DCLevel class],
      HOUSEPLANS_URI : [DCHousePlan class],
      TRACKS_URI : [DCTrack class],
      SESSIONS_URI : [DCMainEvent class],
      BOFS_URI : [DCBof class],
      SOCIAL_EVENTS_URI : [DCSocialEvent class],
      LOCATIONS_URI : [DCLocation class],
      POI_URI : [DCPoi class],
      INFO_URI : [DCInfo class],
      TWITTER_URI : [DCTwitter class]
    };
  }
  return _classesMap;
}

#pragma mark - TimeStamp operations

// Save time stamp in NSUserDefaults with key [DCImportDataSevice class]
- (NSString*)timeStampValue {
  return [NSUserDefaults lastModify];
}

- (void)updatelastModify:(NSString*)value {
  [NSUserDefaults updateLastModify:value];
}

#pragma mark - Import operations status callbacks
- (void)importFinishedWithStatus:(DCImportDataSeviceImportStatus)status {
  //  Update time stamp
  if (status == DCDataUpdateSuccess) {
    [self updatelastModify:self.preLastModified];
  }

  if ([self.delegate
          conformsToProtocol:@protocol(DCImportDataSeviceDelegate)]) {
    [self.delegate importDataServiceFinishedImport:self withStatus:status];
  } else {
    NSParameterAssert(self.delegate);
  }
}

- (void)updateFailed {
  // Clean core data context
  [[[self.coreDataStore class] privateQueueContext] rollback];

  [self importFinishedWithStatus:DCDataUpdateFailed];
}

#pragma mark - Start point for import data process

- (void)chechUpdates {
  NSDictionary* headerParams = nil;
  if (![self isStringEmpty:[self timeStampValue]]) {
    headerParams = [NSDictionary dictionaryWithObject:[self timeStampValue]
                                               forKey:@"If-Modified-Since"];
  }

  [DCWebService
      fetchDataFromURLRequest:[DCWebService urlRequestForURI:CHECK_UPDATES_URI
                                              withHTTPMethod:@"GET"
                                           withHeaderOptions:headerParams]
      onSuccess:^(NSHTTPURLResponse* response, id data) {
        if ([response.allHeaderFields objectForKey:@"Last-Modified"]) {
          self.preLastModified =
              [response.allHeaderFields objectForKey:@"Last-Modified"];
        }
        if (response.statusCode == 304)  // no changes
        {
          [self importFinishedWithStatus:DCDataNotChanged];
          return;
        }

        NSError* err = nil;
        NSDictionary* dictionary =
            [NSJSONSerialization JSONObjectWithData:data
                                            options:kNilOptions
                                              error:&err];
        dictionary = [dictionary dictionaryByReplacingNullsWithStrings];
        if ([dictionary[IDS_FOR_UPDATE] isKindOfClass:[NSArray class]] || err) {
          [self
              importDataForURIs:[self
                                    DC_URIsFromIds:dictionary[IDS_FOR_UPDATE]]];
        } else {
          NSAssert(NO, @"WRONG! API data");
        }
      }
      onError:^(NSHTTPURLResponse* response, id data, NSError* error) {
        NSLog(@"err-%@", error);
        [self handleNetworkError];
      }];
}

- (void)handleNetworkError {
  if ([self isInitDataImport]) {
    [self importFinishedWithStatus:DCDataNotChanged];
  } else {
    [self importFinishedWithStatus:DCDataUpdateFailed];
  }
}

- (void)importDataForURIs:(NSArray*)URIs {
  [self.webService
      fetchesDataFromURLRequests:[self requestsForUpdateFromURIs:URIs]
                        callBack:^(BOOL success, NSDictionary* result) {
                          [self parseData:result
                              withSuccessAction:
                                  @selector(updateCoreDataWithDictionary:)];
                        }];
}

- (void)updateCoreDataWithDictionary:(NSDictionary*)newDict {
  NSDictionary* dict = newDict;

  // Update core data
  NSManagedObjectContext* backgroundContext =
      [[self.coreDataStore class] privateQueueContext];
  [backgroundContext performBlock:^{

    [self fillInModelsFromDictionary:dict inContext:backgroundContext];
    [self.coreDataStore saveWithCompletionBlock:^(BOOL isSuccess) {
      if (isSuccess) {
        [self importFinishedWithStatus:DCDataUpdateSuccess];
      } else {
        [self updateFailed];
      }
    }];

  }];
}

- (NSArray*)requestsForUpdateFromURIs:(NSArray*)uris {
  NSMutableArray* requestsPlaceHolder = [NSMutableArray array];
  for (NSString* uri in uris) {
    NSDictionary* headerParams = nil;
    if (![self isStringEmpty:[self timeStampValue]]) {
      headerParams = [NSDictionary dictionaryWithObject:[self timeStampValue]
                                                 forKey:@"If-Modified-Since"];
    }
    NSURLRequest* request = [DCWebService urlRequestForURI:uri
                                            withHTTPMethod:@"GET"
                                         withHeaderOptions:headerParams];
    [requestsPlaceHolder addObject:request];
  }
  return requestsPlaceHolder;
}

- (void)fillInModelsFromDictionary:(NSDictionary*)dict
                         inContext:(NSManagedObjectContext*)context {
  for (NSString* keyUri in _resourceURIs) {
    // Get class map to URI
    Class model = self.classesMap[keyUri];
    // Check is model can update with dictionary
    if ([model conformsToProtocol:@protocol(ManagedObjectUpdateProtocol)]) {
      [model updateFromDictionary:dict[keyUri] inContext:context];
    } else if (model) {
      NSAssert(NO, @"Model cann't be updated because it doesn't have "
               @"ManagedObjectUpdateProtocol");
    }
  }
}

- (void)parseData:(NSDictionary*)data withSuccessAction:(SEL)successSelector {
  DCParserService* parserService = [[DCParserService alloc] init];
  [parserService
      parseJSONDataFromDictionary:data
                     withCallBack:
                         [self parseCallBackWithSuccessAction:successSelector]];
}

- (CompleteParseCallback)parseCallBackWithSuccessAction:(SEL)successSelector;
{
  CompleteParseCallback callback = ^(NSError* error, NSDictionary* result) {
    if (!error) {
      [self performSelectorOnMainThread:successSelector
                             withObject:result
                          waitUntilDone:NO];
    } else {
      NSLog(@"Parse failed");
      [self updateFailed];
    }

  };
  return callback;
}

#pragma mark - private

- (NSArray*)DC_URIsFromIds:(NSArray*)Ids {
  NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:Ids.count];
  for (NSString* Id in Ids) {
    [result addObject:[self DC_URIFromId:Id]];
  }
  self.resourceURIs = result;
  return result;
}

- (NSString*)DC_URIFromId:(NSString*)Id {
  NSInteger intId = [Id integerValue];

  NSString* result = @"";
  switch (intId) {
    case 1:
      result = TYPES_URI;
      break;

    case 2:
      result = LEVELS_URI;
      break;

    case 3:
      result = TRACKS_URI;
      break;

    case 4:
      result = SPEAKERS_URI;
      break;

    case 5:
      result = LOCATIONS_URI;
      break;

    case 6:
      result = HOUSEPLANS_URI;
      break;

    case 7:
      result = SESSIONS_URI;
      break;

    case 8:
      result = BOFS_URI;
      break;

    case 9:
      result = SOCIAL_EVENTS_URI;
      break;

    case 10:
      result = POI_URI;
      break;

    case 11:
      result = INFO_URI;
      break;

    case 12:
      result = TWITTER_URI;
      break;

    default:
      result = SETTINGS_URI;
      break;
  }

  return result;
}

@end
