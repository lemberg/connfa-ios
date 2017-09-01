//
//  DCEvent+CoreDataClass.h
//  Connfa
//
//  Created by Oleh Kurnenkov on 5/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DCTrack+CoreDataProperties.h"

@class DCLevel, DCSharedSchedule, DCSpeaker, DCTimeRange, DCType;

NS_ASSUME_NONNULL_BEGIN

@interface DCEvent : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "DCEvent+CoreDataProperties.h"
