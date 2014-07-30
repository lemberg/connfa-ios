//
//  DCTimeRangeForGrouper.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import "DCTimeRangeForGrouper.h"

@implementation DCTimeRangeForGrouper

-(id) initWithFrom: (NSString*) from to:(NSString*) to {
    self = [super init];
    
    /*
    float fromHour = [[[from componentsSeparatedByString: @":"] objectAtIndex: 0] floatValue];
    float fromMinutes = [[[from componentsSeparatedByString: @":"] objectAtIndex: 1] floatValue];
    
    float toHour = [[[to componentsSeparatedByString: @":"] objectAtIndex: 0] floatValue];
    float toMinutes = [[[to componentsSeparatedByString: @":"] objectAtIndex: 1] floatValue];
     
    
    self.from = fromHour + fromMinutes/60.;
    self.to = toHour + toMinutes/60.;
     */
    
    self.from = from;
    self.to = to;
    
    return self;
}

-(NSString*) state {
    return [NSString stringWithFormat: @"%@-%@", self.from, self.to];
}

-(id) initWithText: (NSString*) text {
    self = [super init];
    self.from = [[text componentsSeparatedByString: @"-"] objectAtIndex: 0];
    self.to = [[text componentsSeparatedByString: @"-"] objectAtIndex: 1];
    return self;
}


@end
