//
//  DCInfoCategory+DC.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 12/19/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCInfoCategory.h"
#import "DCManagedObjectUpdateProtocol.h"


extern NSString *kDCInfoCategoryId;
extern NSString *kDCInfoCategoryTitle;
extern NSString *kDCInfoCategoryHTML;

@interface DCInfoCategory (DC) <ManagedObjectUpdateProtocol>

@end
