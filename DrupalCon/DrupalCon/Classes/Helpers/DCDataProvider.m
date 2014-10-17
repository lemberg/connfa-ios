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

#import "DCDataProvider.h"


@implementation DCDataProvider

+ (void)updateMainDataFromFile:(NSString *)fileName callBack:(DataProviderCallBack)callBack
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    
    if (filePath)
    {
        NSError * err = nil;
        NSData * result = [NSData dataWithContentsOfFile:filePath
                                                 options:NSDataReadingUncached
                                                   error:&err];
        if (err) {
            callBack(NO, err, @"");
        }
        else
        {
            callBack(YES, result, @"");
        }
    }
    else
    {
        callBack(NO, @"no json file", @"");
    }
}

+ (void)updateMainDataFromURI:(NSString *)uri lastModified:(NSString *)lastModified callBack:(DataProviderCallBack)callBack
{
    NSURL *requestURL = [NSURL URLWithString:uri relativeToURL:[NSURL URLWithString:BASE_URL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setValue:lastModified forHTTPHeaderField:@"If-Modified-Since"];
    [request setHTTPMethod:@"GET"];
    [request setURL:requestURL];
    NSError * error = nil;
    NSHTTPURLResponse* response = nil;
    //Capturing server response
    NSData *data = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    BOOL success = YES;
    NSString * lastModifiedResponce = nil;
    if (error)
    {
        callBack (!success, data, lastModifiedResponce);
    }
    
    else if (response.statusCode == 304) // there is no modify
    {
        callBack (success, data, lastModifiedResponce);
    }
    else if (response.statusCode == 200)
    {
        lastModifiedResponce = [NSString stringWithFormat:@"%@", [[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Last-Modified"]];
        callBack(success, data, lastModifiedResponce);
    }
    else
    {
        callBack (!success, data, lastModifiedResponce);
    }
}



@end
