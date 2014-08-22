//
//  DCTimeRange+DC.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/21/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCTimeRange.h"

@interface DCTimeRange (DC)

- (void)setFrom:(NSString*)from to:(NSString*)to;
- (BOOL)isEqualTo:(DCTimeRange*)timeRange;

- (NSString*)stringValue;

@end
