//
//  DCTestContentGenerator.h
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCTestContentGenerator : NSObject
+(NSArray*) simulateConferenceItems;
+(NSArray*) group: (NSMutableArray*) arrayOfDaysInConference;
@end
