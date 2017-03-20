
#import "DCParserService.h"
#import "NSDictionary+DC.h"
#import "NSArray+DC.h"

@interface DCParserService ()

@property(strong, nonatomic) NSOperationQueue* operationQueue;
@property(strong, nonatomic) NSMutableDictionary* dataResults;
@property(strong, nonatomic) NSError* parseError;

@end

@implementation DCParserService

- (instancetype)init {
  if (self = [super init]) {
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 3;
    self.dataResults = [NSMutableDictionary dictionary];
  }
  return self;
}

+ (void)parseJSONData:(NSData*)jsonData
         withCallBack:(CompleteParseCallback)callback {
  NSError* err = nil;
  NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:kNilOptions
                                                               error:&err];
  dictionary = [dictionary dictionaryByReplacingNullsWithStrings];
  callback(err, dictionary);
}

- (void)parseJSONDataFromDictionary:(NSDictionary*)jsonData
                       withCallBack:(CompleteParseCallback)callback {
  NSAssert(jsonData, @"Json data is empty");

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    [self.operationQueue
            addOperations:[self parserOperationsFromDictionary:jsonData]
        waitUntilFinished:YES];
    callback(self.parseError, self.dataResults);
  });
}

- (NSArray*)parserOperationsFromDictionary:(NSDictionary*)dict {
  NSMutableArray* operations = [NSMutableArray array];
  for (NSString* key in [dict allKeys]) {
    NSBlockOperation* parseOperation =
        [self parserOperationForKey:key andData:dict[key]];
    [operations addObject:parseOperation];
  }
  return operations;
}

- (NSBlockOperation*)parserOperationForKey:(NSString*)key
                                   andData:(NSData*)data {
  NSBlockOperation* parseOperation =
      [NSBlockOperation blockOperationWithBlock:^{
        [DCParserService parseJSONData:data
                          withCallBack:[self parseCallbackForKey:key]];
      }];

  return parseOperation;
}

- (CompleteParseCallback)parseCallbackForKey:(NSString*)key {
  CompleteParseCallback callback = ^(NSError* error, NSDictionary* result) {
    if (result.allKeys.count > 0 && !error) {
      [self addData:result forKey:key];
      return;
    }
    if (error.code == 3840) {
      NSLog(@"Parse failed in key %@ with no value %@", key, error);
    } else {
      //// Set error
      @synchronized(self) {
        [self.operationQueue cancelAllOperations];
        self.parseError = error;
      }
      NSLog(@"Parse failed in key %@ withError %@", key, error);
    }
  };
  return callback;
}

- (void)addData:(id)responseData forKey:(NSString*)key {
  NSAssert(responseData, @"Repsonse from server is empty");
  NSAssert(key, @"Key is missed");
  @synchronized(self) {
    [self.dataResults setObject:responseData forKey:key];
  }
}

@end
