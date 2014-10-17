//
//  DCParseProtocol.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 10/16/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

@protocol parseProtocol <NSObject>

+ (BOOL)successParceJSONData:(NSData*)jsonData;
+ (NSString*)idKey;

@end

static NSString * kDCParseObjectDeleted = @"objectDeleted";

@interface DCParseProtocol : NSObject;

@end