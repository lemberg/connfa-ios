//
//  DCLocation+DC.h
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/3/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCLocation.h"
#import "DCMainProxy.h"

@interface DCLocation (DC)

+ (void)parceFromJsonData:(NSData *)jsonData;

@end
