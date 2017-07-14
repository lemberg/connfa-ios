//
//  DCTrack+CoreDataProperties.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 5/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCTrack+CoreDataProperties.h"

@implementation DCTrack (CoreDataProperties)

+ (NSFetchRequest<DCTrack *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCTrack"];
}

@dynamic name;
@dynamic order;
@dynamic selectedInFilter;
@dynamic trackId;
@dynamic events;

@end
