//
//  DCTrack+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCTrack+DC.h"
#import "DCMainProxy.h"
#import "NSDictionary+DC.h"

NSString * kDCTrack_traks_key = @"tracks";
NSString * kDCTrack_trackID_key = @"trackID";
NSString * kDCTrack_trackName_key = @"trackName";

@implementation DCTrack (DC)

+ (void)parseFromJsonData:(NSData *)jsonData
{
    NSError * err = nil;
    NSDictionary * tracks = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:kNilOptions
                                                              error:&err];
    tracks = [tracks dictionaryByReplacingNullsWithStrings];
    if (err)
    {
        NSLog(@"WRONG! json");
        @throw [NSException exceptionWithName:INVALID_JSON_EXCEPTION reason:@"Problem in json structure" userInfo:nil];
        return;
    }
    
    for (NSDictionary * dictionary in tracks[kDCTrack_traks_key])
    {
        DCTrack * track = [[DCMainProxy sharedProxy] createTrack];
        track.trackId = dictionary[kDCTrack_trackID_key];
        track.name = dictionary[kDCTrack_trackName_key];
    }
    
}
@end
