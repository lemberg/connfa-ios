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
