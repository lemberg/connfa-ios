//
//  DCTimeRange+CoreDataProperties.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 5/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCTimeRange+CoreDataProperties.h"

@implementation DCTimeRange (CoreDataProperties)

+ (NSFetchRequest<DCTimeRange *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCTimeRange"];
}

@dynamic from;
@dynamic to;

@end
