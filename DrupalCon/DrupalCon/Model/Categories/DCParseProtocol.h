//
//  DCParseProtocol.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 10/16/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

@protocol parseProtocol <NSObject>

+ (BOOL)successParceJSONData:(NSData*)jsonData idsForRemove:(NSArray**)idsForRemove;
+ (NSString*)idKey;

@end

static NSString * kDCParcesObjectsToAdd = @"objectsToAdd";
static NSString * kDCParcesObjectsToRemove = @"objectsToRemove";

@interface DCParseProtocol : NSObject;

@end