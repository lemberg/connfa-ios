//
//  DCDataProvider.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
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
            callBack(NO, err);
        }
        else
        {
            callBack(YES, result);
        }
    }
    else
    {
        callBack(NO, @"no json file");
    }
}

+ (void)updateMainDataFromURI:(NSString *)uri callBack:(DataProviderCallBack)callBack
{
    NSURL *requestURL = [NSURL URLWithString:uri relativeToURL:[NSURL URLWithString:SERVER_URL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:requestURL];
    NSError * error = nil;
    NSURLResponse* response;
    //Capturing server response
    NSData *data = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if (error == nil)
    {
        // Parse data here
        callBack(YES, data);
    } else {
        callBack (NO, data);
    }
    
}



@end
