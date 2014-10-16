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
        DCLocation * locationData = [[DCMainProxy sharedProxy] createLocation];
        locationData.latitude = venue[kDCLocationLatitude];
        locationData.longitude = venue[kDCLocationLongitude];
        locationData.name = venue[kDCLocationPlaceName];
        locationData.streetName = venue[kDCLocationStreetName];
        locationData.number = venue[kDCLocationBuildNum];
    }
}

#pragma mark - parseProtocol

+ (BOOL)successParceJSONData:(NSData *)jsonData idsForRemove:(NSArray *__autoreleasing *)idsForRemove
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
    for (NSDictionary *venue in location[kDCLocation]) {
        DCLocation * locationData = [[DCMainProxy sharedProxy] createLocation];
        locationData.latitude = venue[kDCLocationLatitude];
        locationData.longitude = venue[kDCLocationLongitude];
        locationData.name = venue[kDCLocationPlaceName];
        locationData.streetName = venue[kDCLocationStreetName];
        locationData.number = venue[kDCLocationBuildNum];
    }
    
    
    //colelct objects ids for removing
    if (location[kDCParcesObjectsToRemove])
    {
        NSMutableArray * idsForRemoveMut = [[NSMutableArray alloc] initWithCapacity:[(NSArray*)location[kDCParcesObjectsToRemove] count]];
        for (NSDictionary * idDictiuonary in location[kDCParcesObjectsToRemove])
        {
            [idsForRemoveMut addObject:idDictiuonary[kDCLocationID]];
        }
        * idsForRemove  = [[NSArray alloc] initWithArray:idsForRemoveMut];
    }
    
    return YES;
}

+ (NSString*)idKey
{
    return (NSString*)kDCLocationID;
}

@end
