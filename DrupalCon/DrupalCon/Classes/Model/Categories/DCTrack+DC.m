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
#import "NSManagedObject+DC.h"

NSString * kDCTracksKey = @"tracks";
NSString * kDCTrackIdKey = @"trackId";
NSString * kDCTrackNameKey = @"trackName";
NSString * kDCTrackSelectedInFilter = @"trackSelectedInFilter";

@implementation DCTrack (DC)

#pragma mark - ManagedObjectUpdateProtocol
+ (void)updateFromDictionary:(NSDictionary *)tracks inContext:(NSManagedObjectContext *)context
{
    //adding
    for (NSDictionary * dictionary in tracks[kDCTracksKey])
    {
        DCTrack * track = (DCTrack*)[[DCMainProxy sharedProxy] objectForID:[dictionary[kDCTrackIdKey] intValue]
                                                                   ofClass:[DCTrack class]
                                                                 inContext:context];
        
        if (!track) // then create
        {
            track = [DCTrack createManagedObjectInContext:context];//(DCTrack*)[[DCMainProxy sharedProxy] createObjectOfClass:[DCTrack class]];
            track.selectedInFilter = [NSNumber numberWithBool:YES];
        }
        
        if ([dictionary[kDCParseObjectDeleted] intValue]==1) // remove
        {
            [[DCMainProxy sharedProxy] removeItem:track];
        }
        else // update
        {
            track.trackId = dictionary[kDCTrackIdKey];
            track.name = dictionary[kDCTrackNameKey];
            track.order = [NSNumber numberWithFloat:[dictionary[kDCParseObjectOrderKey] floatValue]];
        }
    }
}


+ (NSString*)idKey
{
    return (NSString*)kDCTrackIdKey;
}

@end
