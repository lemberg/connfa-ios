//
//  DCLevel+CoreDataProperties.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 5/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCLevel+CoreDataProperties.h"

@implementation DCLevel (CoreDataProperties)

+ (NSFetchRequest<DCLevel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCLevel"];
}

@dynamic levelId;
@dynamic name;
@dynamic order;
@dynamic selectedInFilter;
@dynamic events;

@end
