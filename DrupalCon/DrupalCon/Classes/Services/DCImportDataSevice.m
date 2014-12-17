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


#import "DCImportDataSevice.h"

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

#import "DCWebService.h"
#import "DCParserService.h"

#import "NSUserDefaults+DC.h"

static NSString *const CHECK_UPDATES_URI   = @"checkUpdates";
static NSString *const TYPES_URI      = @"getTypes";
static NSString *const LEVELS_URI     = @"getLevels";
static NSString *const TRACKS_URI     = @"getTracks";
static NSString *const SPEAKERS_URI    = @"getSpeakers";
static NSString *const LOCATIONS_URI  = @"getLocations";
static NSString *const SESSIONS_URI   = @"getSessions";
static NSString *const BOFS_URI       = @"getBofs";
static NSString *const SOCIAL_EVENTS_URI = @"getSocialEvents";
static NSString *const POI_URI        = @"getPOI";
static NSString *const INFO_URI       = @"getInfo";
static NSString *const TWITTER_URI    = @"getTwitter";



@interface DCImportDataSevice()

@property (nonatomic, strong) DCWebService *webService;
@property (nonatomic, strong) NSDictionary *classesMap;

@end

@implementation DCImportDataSevice


- (instancetype)initWithManagedObjectContext:(DCCoreDataStore *)coreDataStore
                                 andDelegate:(id<DCImportDataSeviceDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.coreDataStore  = coreDataStore;
        self.delegate       = delegate;
        // Initialise web service
        self.webService = [[DCWebService alloc] init];
    }
    return self;
}


- (BOOL)isInitDataImport
{
    NSString *timestamp = [self timeStampValue];
    
    return [self isStringEmpty:timestamp];
}

- (BOOL)isStringEmpty:(NSString *)string
{
    return !string || [string length] == 0 ;
}

- (NSDictionary *)classesMap
{
    if  (!_classesMap) {
        _classesMap =  @{ TYPES_URI: [DCType class],
                          SPEAKERS_URI: [DCSpeaker class],
                          LEVELS_URI: [DCLevel class],
                          TRACKS_URI: [DCTrack class],
                          SESSIONS_URI: [DCProgram class],
                          BOFS_URI: [DCBof class],
                          LOCATIONS_URI: [DCLocation class]
                          };
    }
    return _classesMap;
}

#pragma mark - TimeStamp operations

// Save time stamp in NSUserDefaults with key [DCImportDataSevice class]
- (NSString *)timeStampValue
{
    return [NSUserDefaults lastModify];
}

- (void)updatelastModify:(NSString *)value
{
    [NSUserDefaults updateLastModify:value];
}

# pragma mark - Import operations status callbacks
- (void)importFinishedWithStatus:(DCImportDataSeviceImportStatus)status
{
    //  Update time stamp
    if (status == DCDataUpdateSuccess) {
        
        [self updatelastModify:@"11111111111"];
    }
    
    if ([self.delegate conformsToProtocol:@protocol(DCImportDataSeviceDelegate)]) {
        [self.delegate importDataServiceFinishedImport:self withStatus:status];
    } else {
        NSParameterAssert(self.delegate);
    }
    
}

- (void)updateFailed
{
    // Clean core data context
    [[[self.coreDataStore class] privateQueueContext] rollback];
    
    [self importFinishedWithStatus:DCDataUpdateFailed];
    
}

#pragma mark - Start point for import data process

- (void)chechUpdates
{
    //  TODO: Make request to server due to update time stamp and get the response with latest changes
    [self.webService fetchesDataFromURLRequests:[self requestsForUpdateFromURIs:@[CHECK_UPDATES_URI]] callBack:^(BOOL success, NSDictionary *result) {
        
    }];
    
}

- (void)importDataForURIs:(NSArray*)URIs
{
    
}




- (void)updateCoreDataWithDictionary:(NSDictionary *)newDict
{
    NSDictionary *dict = newDict;
    
    // TODO: Create model for this information, now I don't know what todo
    [NSUserDefaults saveAbout:dict[ABOUT_INFO_URI][kAboutInfo]];
    
    // Update core data
    NSManagedObjectContext *backgroundContext = [[self.coreDataStore class] privateQueueContext];
    [backgroundContext  performBlock:^{
        
        [self fillInModelsFromDictionary:dict inContext:backgroundContext];
        
        if ([self.coreDataStore save]) {
            [self importFinishedWithStatus:DCDataUpdateSuccess];
        } else {
            [self updateFailed];
        }
        
    }];
    
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


#pragma mark - private

- (NSArray*)DC_URIsFromIds:(NSArray*)Ids
{
    NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity:Ids.count];
    for (NSString * Id in Ids)
    {
        [result addObject:[self DC_URIFromId:Id]];
    }
    return result;
}

- (NSString*)DC_URIFromId:(NSString*)Id
{
    NSInteger intId = [Id integerValue];
    if (!intId)
        @throw [[NSException alloc] initWithName:@"API" reason:@"method id can't be 0" userInfo:nil];
    
    NSString * result = @"";
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
            result = SESSIONS_URI;
            break;
            
        case 7:
            result = BOFS_URI;
            break;
            
        case 8:
            result = SOCIAL_EVENTS_URI;
            break;
            
        case 9:
            result = POI_URI;
            break;
            
        case 10:
            result = INFO_URI;
            break;
            
        case 11:
            result = TWITTER_URI;
            break;
            
        default:
            break;
    }
    
    return result;
}

@end
