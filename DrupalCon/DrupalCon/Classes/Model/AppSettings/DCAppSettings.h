//
//  DCAppSettings.h
//  DrupalCon
//
//  Created by Olexandr on 7/7/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DCAppSettings : NSManagedObject

@property(nonatomic, retain) NSNumber* eventTimeZone;

@end
