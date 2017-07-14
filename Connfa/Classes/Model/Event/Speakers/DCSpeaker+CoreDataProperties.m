//
//  DCSpeaker+CoreDataProperties.m
//  Connfa
//
//  Created by Oleh Kurnenkov on 5/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCSpeaker+CoreDataProperties.h"

@implementation DCSpeaker (CoreDataProperties)

+ (NSFetchRequest<DCSpeaker *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCSpeaker"];
}

@dynamic avatarPath;
@dynamic characteristic;
@dynamic firstName;
@dynamic jobTitle;
@dynamic lastName;
@dynamic name;
@dynamic order;
@dynamic organizationName;
@dynamic sectionKey;
@dynamic speakerId;
@dynamic twitterName;
@dynamic webSite;
@dynamic events;

@end
