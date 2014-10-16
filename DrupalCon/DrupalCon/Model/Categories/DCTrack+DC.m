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

#import "DCTrack+DC.h"
#import "DCMainProxy.h"
#import "NSDictionary+DC.h"

NSString * kDCTrack_traks_key = @"tracks";
NSString * kDCTrack_trackID_key = @"trackID";
NSString * kDCTrack_trackName_key = @"trackName";

@implementation DCTrack (DC)

#pragma mark - parseProtocol

+ (BOOL)successParceJSONData:(NSData *)jsonData idsForRemove:(NSArray *__autoreleasing *)idsForRemove
{
    NSError * err = nil;
    NSDictionary * tracks = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:kNilOptions
                                                              error:&err];
    tracks = [tracks dictionaryByReplacingNullsWithStrings];
    
    if (err)
    {
        @throw [NSException exceptionWithName:INVALID_JSON_EXCEPTION reason:@"Problem in json structure" userInfo:nil];
        return NO;
    }
    
    //adding
    for (NSDictionary * dictionary in tracks[kDCParcesObjectsToAdd])
    {
        DCTrack * track = [[DCMainProxy sharedProxy] createTrack];
        track.trackId = dictionary[kDCTrack_trackID_key];
        track.name = dictionary[kDCTrack_trackName_key];
    }
    
    
    //colelct objects ids for removing
    if (tracks[kDCParcesObjectsToRemove])
    {
        NSMutableArray * idsForRemoveMut = [[NSMutableArray alloc] initWithCapacity:[(NSArray*)tracks[kDCParcesObjectsToRemove] count]];
        for (NSDictionary * idDictiuonary in tracks[kDCParcesObjectsToRemove])
        {
            [idsForRemoveMut addObject:idDictiuonary[kDCTrack_trackID_key]];
        }
        * idsForRemove  = [[NSArray alloc] initWithArray:idsForRemoveMut];
    }
    
    return YES;
}

+ (NSString*)idKey
{
    return (NSString*)kDCTrack_trackID_key;
}

@end
