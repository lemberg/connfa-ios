/*
 Copyright (c) 2011, Tony Million.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

/**
 *  DCWebService manages http request/repsponse
 */
typedef void (^SuccessResponseCallback)(NSHTTPURLResponse *response, id data);
typedef void (^FailureResponseCallback)(NSHTTPURLResponse *response, id data, NSError *error);
typedef void (^CompleteRequestCallback)(BOOL success, NSDictionary *result);

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
- (NSURLRequest *)urlRequestForURI:(NSString *)uri
                    withHTTPMethod:(NSString *)httpMethod
                 withHeaderOptions:(NSDictionary *)options;

/**
 *  Fetches data from server asynchronously
 *
 *  @param urlRequest      NSURLRequest object with URL request, Http method etc.
 *  @param successCallback call when request is success in global queue
 *  @param failureCallback call when request is failure in global queue
 */
- (void)fetchDataFromURLRequest:(NSURLRequest *)urlRequest
                      onSuccess:(SuccessResponseCallback)successCallback
                        onError:(FailureResponseCallback)failureCallback;


/**
 *  Fetches data from server asynchronously
 *
 *  @param requests arrar with NSURLRequest objects
 *  @param callback call in globar queue when all requests has finished
 */
- (void)fetchesDataFromURLRequests:(NSArray *)requests callBack:(CompleteRequestCallback)callback;


@end
