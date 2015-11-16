//
//  NSManagedObject+DC.m
//  DrupalCon
//
//  Created by Olexandr on 10/30/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "NSManagedObject+DC.h"

@implementation NSManagedObject (DC)

+ (instancetype)createManagedObjectInContext:(NSManagedObjectContext*)context {
  NSEntityDescription* entity =
      [NSEntityDescription entityForName:NSStringFromClass([self class])
                  inManagedObjectContext:context];
  return [[[self class] alloc] initWithEntity:entity
               insertIntoManagedObjectContext:context];
}

@end
