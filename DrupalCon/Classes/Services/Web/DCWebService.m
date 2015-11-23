
#import "DCWebService.h"
#import "DCAppConfiguration.h"
//#warning Remove this and move SERVER URL in this file
//#import "DCDataProvider.h"

@interface DCWebService ()

@property(strong, nonatomic) NSOperationQueue* operationQueue;
@property(strong, nonatomic) NSMutableDictionary* dataResults;
@property BOOL isOperationsFailed;

@end

@implementation DCWebService

- (instancetype)init {
  if (self = [super init]) {
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 3;
    self.dataResults = [NSMutableDictionary dictionary];
  }
  return self;
}

#pragma mark - PUBLIC

+ (NSURLRequest*)urlRequestForURI:(NSString*)uri
                   withHTTPMethod:(NSString*)httpMethod
                withHeaderOptions:(NSDictionary*)options {
  NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];

  //    TODO: Remove testing property in getParameter
  NSString* testUriParameter =
      uri;  //[NSString stringWithFormat:@"%@/?testing=1", uri];
  NSURL* requestURL = [NSURL URLWithString:testUriParameter
                             relativeToURL:[NSURL URLWithString:BASE_URL]];
  [request setURL:requestURL];
  request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
  [request setHTTPMethod:httpMethod];

  if (options) {
    for (NSString* key in [options allKeys]) {
      [request setValue:options[key] forHTTPHeaderField:key];
    }
  }

  return request;
}

+ (void)fetchDataFromURLRequest:(NSURLRequest*)urlRequest
                      onSuccess:(SuccessResponseCallback)successCallback
                        onError:(FailureResponseCallback)failureCallback {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    [self dataFromURLRequest:urlRequest
                   onSuccess:successCallback
                     onError:failureCallback];
  });
}

- (void)resetParameters {
  [self.dataResults removeAllObjects];
  self.isOperationsFailed = NO;
}

- (void)fetchesDataFromURLRequests:(NSArray*)requests
                          callBack:(CompleteRequestCallback)callback {
  [self resetParameters];
  // Go to background
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    // Add operations in queue
    [self.operationQueue addOperations:[self operationsFromUrlRequests:requests]
                     waitUntilFinished:YES];

    // All operations have already finished
    callback(!self.isOperationsFailed,
             [NSDictionary dictionaryWithDictionary:self.dataResults]);
    [self resetParameters];

  });
}

+ (void)dataFromURLRequest:(NSURLRequest*)urlRequest
                 onSuccess:(SuccessResponseCallback)successCallback
                   onError:(FailureResponseCallback)failureCallback {
  NSError* error = nil;
  NSHTTPURLResponse* response = nil;

  NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest
                                       returningResponse:&response
                                                   error:&error];

  if (error) {
    failureCallback(response, data, error);
  } else {
    successCallback(response, data);
  }
}

#pragma mark - PRIVATE:

#pragma mark Create operation objects
- (NSArray*)operationsFromUrlRequests:(NSArray*)requests {
  // Create operation placholder
  NSMutableArray* operations = [NSMutableArray array];
  // Create request operation for the each request
  for (NSURLRequest* request in requests) {
    // Create block operation with url request
    NSBlockOperation* requestOperation =
        [NSBlockOperation blockOperationWithBlock:^{
          [DCWebService dataFromURLRequest:request
                                 onSuccess:[self successResponseCallback]
                                   onError:[self failureResponseCallback]];
        }];

    [operations addObject:requestOperation];
  }
  return [NSArray arrayWithArray:operations];
}

- (SuccessResponseCallback)successResponseCallback {
  SuccessResponseCallback success = ^(NSHTTPURLResponse* response, id data) {
    [self addResponseData:data
                   forKey:[self uriSufixFromResourseString:
                                    response.URL.resourceSpecifier]];
  };

  return success;
}

- (FailureResponseCallback)failureResponseCallback {
  FailureResponseCallback failure =
      ^(NSHTTPURLResponse* response, id data, NSError* error) {

        [self.operationQueue cancelAllOperations];

        @synchronized(self) {
          self.isOperationsFailed = YES;
        }
      };

  return failure;
}

- (void)addResponseData:(id)responseData forKey:(NSString*)key {
  NSAssert(responseData, @"Repsonse from server is empty");
  NSAssert(key, @"Key is missed");
  @synchronized(self) {
    [self.dataResults setObject:responseData forKey:key];
  }
}

//  FIXME: Create another procedure for KEY to save appropriate server responses
- (NSString*)uriSufixFromResourseString:(NSString*)resourceSpecifier {
  NSString* getSuffix =
      [[resourceSpecifier componentsSeparatedByString:@"/get"] lastObject];
  NSString* sufix = [[getSuffix componentsSeparatedByString:@"/"] firstObject];
  return [NSString stringWithFormat:@"get%@", sufix];
}

@end
