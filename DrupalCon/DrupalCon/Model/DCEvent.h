//
//  DCEvent.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCType;

@interface DCEvent : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * desctiptText;
@property (nonatomic, retain) NSString * place;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * level;
@property (nonatomic, retain) NSString * timeRange;
@property (nonatomic, retain) NSString * track;
@property (nonatomic, retain) NSString * speakers;
@property (nonatomic, retain) DCType *type;

@end
