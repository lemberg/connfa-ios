//
//  DCEvent+CoreDataProperties.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 5/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCEvent+CoreDataProperties.h"

@implementation DCEvent (CoreDataProperties)

+ (NSFetchRequest<DCEvent *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCEvent"];
}

@dynamic calendarId;
@dynamic date;
@dynamic desctiptText;
@dynamic eventId;
@dynamic favorite;
@dynamic link;
@dynamic name;
@dynamic order;
@dynamic place;
@dynamic level;
@dynamic schedules;
@dynamic speakers;
@dynamic timeRange;
@dynamic tracks;
@dynamic type;

@end
