//
//  NSArray+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/21/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "NSArray+DC.h"

@implementation NSArray (DC)

- (NSArray*)objectsFromDictionaries
{
    if (self.count>0)
    {
        if ([self.firstObject isKindOfClass:[NSDictionary class]])
        {
            NSArray* keys = [(NSDictionary*)self.firstObject allKeys];
            if (keys.count == 1)
            {
                NSString * key = keys.firstObject;
                NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.count];
                for (NSDictionary * dict in self)
                {
                    [result addObject:dict[key]];
                }
                return result;
            }
        }
    }
    NSLog(@"WRONG! method used");
    return self;
}

@end
