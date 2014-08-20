//
//  DCTimeRange.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCTimeRange : NSObject
@property (nonatomic, strong) NSString *from;
@property (nonatomic, strong) NSString *to;

-(id) initWithFrom: (NSString*) fromTimeStr to: (NSString*) toTimeStr;
@end
