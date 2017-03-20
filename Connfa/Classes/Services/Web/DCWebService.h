
#import <Foundation/Foundation.h>

/**
 *  DCWebService manages http request/repsponse
 */
typedef void (^SuccessResponseCallback)(NSHTTPURLResponse* response, id data);
typedef void (^FailureResponseCallback)(NSHTTPURLResponse* response,
                                        id data,
                                        NSError* error);
typedef void (^CompleteRequestCallback)(BOOL success, NSDictionary* result);

@interface DCWebService : NSObject

/**
 *  Create NSURLRequest
 *
 *  @param uri        e.g path for resources
 *  @param httpMethod GET, POST, PUT
 *  @param options    header description with key and value
 *
 *  @return NSURLRequest
 */
+ (NSURLRequest*)urlRequestForURI:(NSString*)uri
                   withHTTPMethod:(NSString*)httpMethod
                withHeaderOptions:(NSDictionary*)options;

/**
 *  Fetch data from server synchronously accroding to urlRequest in the call
 *thread
 *
 *  @param urlRequest      NSURLRequest object with URL request, Http method
 *etc.
 *  @param successCallback request is success
 *  @param failureCallback request failed
 */

+ (void)dataFromURLRequest:(NSURLRequest*)urlRequest
                 onSuccess:(SuccessResponseCallback)successCallback
                   onError:(FailureResponseCallback)failureCallback;

/**
 *  Fetches data from server asynchronously
 *
 *  @param urlRequest      NSURLRequest object with URL request, Http method
 *etc.
 *  @param successCallback call when request is success in global queue
 *  @param failureCallback call when request is failure in global queue
 */
+ (void)fetchDataFromURLRequest:(NSURLRequest*)urlRequest
                      onSuccess:(SuccessResponseCallback)successCallback
                        onError:(FailureResponseCallback)failureCallback;

/**
 *  Fetches data from server asynchronously
 *
 *  @param requests array with NSURLRequest objects
 *  @param callback call in globar queue when all requests has finished
 */
- (void)fetchesDataFromURLRequests:(NSArray*)requests
                          callBack:(CompleteRequestCallback)callback;

@end
