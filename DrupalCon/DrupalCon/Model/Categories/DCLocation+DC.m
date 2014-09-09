//
//  DCLocation+DC.m
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/3/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCLocation+DC.h"
#import "NSDictionary+DC.h"

NSString *kDCLocation = @"location";
NSString *kDCLocationLongitude = @"longitude";
NSString *kDCLocationLatitude  = @"latitude";
NSString *kDCLocationPlaceName = @"name";
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
        return;
    }
    NSDictionary *venue = location[kDCLocation];
    
    DCLocation * locationData = [[DCMainProxy sharedProxy] createLocation];
    locationData.latitude = venue[kDCLocationLatitude];
    locationData.longitude = venue[kDCLocationLongitude];
    locationData.name = venue[kDCLocationPlaceName];
    locationData.streetName = venue[kDCLocationStreetName];
    locationData.number = venue[kDCLocationBuildNum];
    

}
@end
