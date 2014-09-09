//
//  NSDictionary+DC.h
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/8/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DC)
- (NSDictionary *)dictionaryByReplacingNullsWithStrings;
@end
