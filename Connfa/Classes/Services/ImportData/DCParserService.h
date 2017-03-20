
#import <Foundation/Foundation.h>

typedef void (^CompleteParseCallback)(NSError* error, NSDictionary* result);

@interface DCParserService : NSObject

/**
 *  Parse json data to NSDictinary synchronously in call thread
 *
 *  @param jsonData data
 *  @param callback call with error and dictionary from jsonData
 */

+ (void)parseJSONData:(NSData*)jsonData
         withCallBack:(CompleteParseCallback)callback;

/**
 *  Parse json data asynchronously from dictionary {key: jsonData}
 *
 *  @param jsonData dictionary
 *  @param callback calls in globar queue when all data have finished parse,
 *                  result will be a dictionary with same KEY as jsonData
 */

- (void)parseJSONDataFromDictionary:(NSDictionary*)jsonData
                       withCallBack:(CompleteParseCallback)callback;

@end
