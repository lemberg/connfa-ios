//
//  DCType+CoreDataProperties.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 5/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCType+CoreDataProperties.h"

@implementation DCType (CoreDataProperties)

+ (NSFetchRequest<DCType *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCType"];
}

@dynamic name;
@dynamic order;
@dynamic typeIcon;
@dynamic typeID;
@dynamic events;

@end
