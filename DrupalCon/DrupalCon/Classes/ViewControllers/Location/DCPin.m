//
//  DCPint.m
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/3/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCPin.h"

@implementation DCPin
-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate
                   title:(NSString *)title {
    
    if (self = [super init]) {
        _title = title;
        _coordinate = coordinate;
    }
    
    return self;
}
@end
