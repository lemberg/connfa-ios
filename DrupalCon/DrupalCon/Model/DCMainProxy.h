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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * INVALID_JSON_EXCEPTION;

@class DCProgram, DCBof, DCType, DCTime, DCTimeRange, DCSpeaker, DCLevel, DCTrack, DCLocation, DCEvent;

typedef enum {
    DCMainProxyStateNone = 0,
    DCMainProxyStateNoData,
    DCMainProxyStateLoadingFail,
    DCMainProxyStateInitDataLoading,
    DCMainProxyStateDataLoading,
    DCMainProxyStateUpdatesWaiting,
    DCMainProxyStateDataReady
}DCMainProxyState;

@interface DCMainProxy : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;

@property (nonatomic) DCMainProxyState state;


+ (DCMainProxy*)sharedProxy;

#pragma mark - public

- (void)update;

#pragma mark - getting instances

- (NSArray*)programInstances;
- (NSArray*)bofInstances;
- (NSArray*)typeInstances;
- (NSArray*)speakerInstances;
- (NSArray*)levelInstances;
- (NSArray*)trackInstances;
- (NSArray *)locationInstances;
- (void)loadHtmlAboutInfo:(void(^)(NSString *))callback;

- (DCType*)typeForID:(int)typeID;
- (DCSpeaker*)speakerForId:(NSInteger)speakerId;
- (DCLevel*)levelForId:(NSInteger)levelId;
- (DCTrack*)trackForId:(NSInteger)trackId;

#pragma mark - creating

- (DCProgram*)createProgramItem;
- (DCBof*)createBofItem;
- (DCType*)createType;
- (DCTime*)createTime;
- (DCSpeaker*)createSpeaker;
- (DCTimeRange*)createTimeRange;
- (DCLevel*)createLevel;
- (DCTrack*)createTrack;
- (DCLocation*)createLocation;

#pragma mark - favorites 

//FIXME: separate Favorites to favoriteManager

- (void)addToFavoriteEvent:(DCEvent *)event;
- (void)removeFavoriteEventWithID:(NSNumber *)eventID;
- (NSArray *)eventsWithIDs:(NSArray *)iDs;
- (void)openLocalNotification:(UILocalNotification *)localNotification;

@end
