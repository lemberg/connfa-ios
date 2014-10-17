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

#import "DCLocation+DC.h"
#import "NSDictionary+DC.h"
#import "DCMainProxy.h"

NSString *kDCLocation = @"locations";
NSString *kDCLocationID = @"loactionID";
NSString *kDCLocationLongitude = @"longitude";
NSString *kDCLocationLatitude  = @"latitude";
NSString *kDCLocationPlaceName = @"locationName";
NSString *kDCLocationStreetName = @"streetName";
NSString *kDCLocationBuildNum = @"number";

@implementation DCLocation (DC)

+ (void)parseFromJsonData:(NSData *)jsonData {

    NSError *err = nil;
    NSDictionary *location = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:kNilOptions
                                                              error:&err];
    location = [location dictionaryByReplacingNullsWithStrings];

    if (err)
    {
        NSLog(@"WRONG! json");
        @throw [NSException exceptionWithName:INVALID_JSON_EXCEPTION reason:@"Problem in json structure" userInfo:nil];
        return;
    }
    
    for (NSDictionary *venue in location[kDCLocation]) {
        DCLocation * locationData = (DCLocation*)[[DCMainProxy sharedProxy] createObjectOfClass:[DCLocation class]];
        locationData.latitude = venue[kDCLocationLatitude];
        locationData.longitude = venue[kDCLocationLongitude];
        locationData.name = venue[kDCLocationPlaceName];
        locationData.streetName = venue[kDCLocationStreetName];
        locationData.number = venue[kDCLocationBuildNum];
    }
}

#pragma mark - parseProtocol

+ (BOOL)successParceJSONData:(NSData *)jsonData
{
    NSError * err = nil;
    NSDictionary * location = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:kNilOptions
                                                                error:&err];
    location = [location dictionaryByReplacingNullsWithStrings];
    
    if (err)
    {
        @throw [NSException exceptionWithName:INVALID_JSON_EXCEPTION reason:@"Problem in json structure" userInfo:nil];
        return NO;
    }
    
    //adding
    for (NSDictionary *dictionary in location[kDCLocation]) {
        DCLocation * location = (DCLocation*)[[DCMainProxy sharedProxy] objectForID:[dictionary[kDCLocationID] intValue] ofClass:[DCLocation class] inMainQueue:NO];
        
        if (!location) // then create
        {
            location = (DCLocation*)[[DCMainProxy sharedProxy] createObjectOfClass:[DCLocation class]];
        }
        
        if ([dictionary[kDCParseObjectDeleted] intValue]==1) // remove
        {
            [[DCMainProxy sharedProxy] removeItem:location];
        }
        else // update
        {
            location.latitude = dictionary[kDCLocationLatitude];
            location.longitude = dictionary[kDCLocationLongitude];
            location.name = dictionary[kDCLocationPlaceName];
            location.streetName = dictionary[kDCLocationStreetName];
            location.number = dictionary[kDCLocationBuildNum];
        }
    }
    
    return YES;
}

+ (NSString*)idKey
{
    return (NSString*)kDCLocationID;
}

@end
