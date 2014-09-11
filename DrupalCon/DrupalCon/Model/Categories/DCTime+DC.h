//
//  DCTime+DC.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/21/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCTime.h"

@interface DCTime (DC)

- (void)setTime:(NSString*)time;

- (NSString*)stringValue;
- (BOOL)isTimeValid;
@end
