/**********************************************************************************
 *                                                                           
 *  The MIT License (MIT)
 *  Copyright (c) 2015 Lemberg Solutions Limited
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the 
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *   The above copyright notice and this permission notice shall be included in
 *   all  copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM,  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 *  IN THE SOFTWARE.
 *
 *                                                                           
 *****************************************************************************/





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
