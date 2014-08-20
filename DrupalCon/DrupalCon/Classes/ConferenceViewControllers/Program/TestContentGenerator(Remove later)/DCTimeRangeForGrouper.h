//
//  DCTimeRangeForGrouper.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCTimeRangeForGrouper : NSObject
@property (nonatomic) NSString *from;
@property (nonatomic) NSString *to;

-(id) initWithFrom: (NSString*) from to:(NSString*) to;
-(NSString*) state;
-(id) initWithText: (NSString*) text;
@end
