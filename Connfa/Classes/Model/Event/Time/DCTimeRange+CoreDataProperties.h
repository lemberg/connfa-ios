//
//  DCTimeRange+CoreDataProperties.h
//  Connfa
//
//  Created by Oleh Kurnenkov on 5/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

#import "DCTimeRange+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCTimeRange (CoreDataProperties)

+ (NSFetchRequest<DCTimeRange *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *from;
@property (nullable, nonatomic, copy) NSDate *to;

@end

NS_ASSUME_NONNULL_END
