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

#import "DCWebService.h"

#warning Remove this and move SERVER URL in this file
#import "DCDataProvider.h"

@interface DCWebService ()

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) NSMutableDictionary *dataResults;
@property BOOL isOperationsFailed;

@end

@implementation DCWebService

- (instancetype)init
{
    if (self = [super init]) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 3;
        self.dataResults = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark - PUBLIC

+ (NSURLRequest *)urlRequestForURI:(NSString *)uri
                    withHTTPMethod:(NSString *)httpMethod
                 withHeaderOptions:(NSDictionary *)options
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSURL *requestURL = [NSURL URLWithString:uri relativeToURL:[NSURL URLWithString:BASE_URL]];
    [request setURL:requestURL];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [request setHTTPMethod:httpMethod];
    
    if (options) {
        for (NSString *key in [options allKeys]) {
            [request setValue:options[key] forHTTPHeaderField:key];
        }
    }
    
    return request;
}


+ (void)fetchDataFromURLRequest:(NSURLRequest *)urlRequest
                      onSuccess:(SuccessResponseCallback)successCallback
                        onError:(FailureResponseCallback)failureCallback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self dataFromURLRequest:urlRequest
                       onSuccess:successCallback
                         onError:failureCallback];
    });
}


- (void)resetParameters
{
    [self.dataResults removeAllObjects];
    self.isOperationsFailed = NO;
}


- (void)fetchesDataFromURLRequests:(NSArray *)requests callBack:(CompleteRequestCallback)callback
{
    [self resetParameters];
    // Go to background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //Add operations in queue
        [self.operationQueue addOperations:[self operationsFromUrlRequests:requests] waitUntilFinished:YES];
        
        //All operations have already finished
        callback(!self.isOperationsFailed, [NSDictionary dictionaryWithDictionary:self.dataResults]);
        [self resetParameters];
        
    });
}




+ (void)dataFromURLRequest:(NSURLRequest *)urlRequest
                 onSuccess:(SuccessResponseCallback)successCallback
                   onError:(FailureResponseCallback)failureCallback
{
    NSError * error = nil;
    NSHTTPURLResponse* response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest  returningResponse:&response error:&error];

    if (error)
    {
        failureCallback(response, data, error);
    } else {
        successCallback(response, data);
    }
    
}

#pragma mark - PRIVATE:

#pragma mark  Create operation objects
- (NSArray *)operationsFromUrlRequests:(NSArray *)requests
{
    // Create operation placholder
    NSMutableArray *operations = [NSMutableArray array];
    // Create request operation for the each request
    for (NSURLRequest *request in requests) {
        // Create block operation with url request
        NSBlockOperation *requestOperation = [NSBlockOperation blockOperationWithBlock:^{
            [DCWebService dataFromURLRequest:request
                           onSuccess:[self successResponseCallback]
                             onError:[self failureResponseCallback]];
        }];
        
        [operations addObject:requestOperation];
    }
    return [NSArray arrayWithArray:operations];
}


- (SuccessResponseCallback)successResponseCallback
{
    SuccessResponseCallback success = ^(NSHTTPURLResponse *response, id data) {
        [self addResponseData:data forKey:[self uriSufixFromResourseString:response.URL.resourceSpecifier]];
    };
    
    return success;
}


- (FailureResponseCallback)failureResponseCallback
{
    FailureResponseCallback failure = ^(NSHTTPURLResponse *response, id data, NSError *error) {
        
        [self.operationQueue cancelAllOperations];
        
        @synchronized(self) {
            self.isOperationsFailed = YES;
        }
    };
    
    return failure;
}

- (void)addResponseData:(id)responseData forKey:(NSString *)key
{
    NSAssert(responseData, @"Repsonse from server is empty");
    NSAssert(key, @"Key is missed");
    @synchronized(self) {
        [self.dataResults setObject:responseData forKey:key];
    }
}

- (NSString *)uriSufixFromResourseString:(NSString *)resourceSpecifier
{
    return [[resourceSpecifier componentsSeparatedByString:@"/"] lastObject];
    
}


@end
