
#import "DCTrack+DC.h"
#import "DCMainProxy.h"
#import "NSDictionary+DC.h"
#import "NSManagedObject+DC.h"

NSString* kDCTracksKey = @"tracks";
NSString* kDCTrackIdKey = @"trackId";
NSString* kDCTrackNameKey = @"trackName";
NSString* kDCTrackSelectedInFilter = @"trackSelectedInFilter";

@implementation DCTrack (DC)

#pragma mark - ManagedObjectUpdateProtocol
+ (void)updateFromDictionary:(NSDictionary*)tracks
                   inContext:(NSManagedObjectContext*)context {
  // adding
  for (NSDictionary* dictionary in tracks[kDCTracksKey]) {
    DCTrack* track = (DCTrack*)[[DCMainProxy sharedProxy]
        objectForID:[dictionary[kDCTrackIdKey] intValue]
            ofClass:[DCTrack class]
          inContext:context];

    if (!track)  // then create
    {
      track = [DCTrack
          createManagedObjectInContext:context];  //(DCTrack*)[[DCMainProxy
      // sharedProxy]
      // createObjectOfClass:[DCTrack
      // class]];
      track.selectedInFilter = [NSNumber numberWithBool:YES];
    }

    if ([dictionary[kDCParseObjectDeleted] intValue] == 1)  // remove
    {
      [[DCMainProxy sharedProxy] removeItem:track];
    } else  // update
    {
      track.trackId = dictionary[kDCTrackIdKey];
      track.name = dictionary[kDCTrackNameKey];
      track.order = [NSNumber
          numberWithFloat:[dictionary[kDCParseObjectOrderKey] floatValue]];
    }
  }
}

+ (NSString*)idKey {
  return (NSString*)kDCTrackIdKey;
}

@end
