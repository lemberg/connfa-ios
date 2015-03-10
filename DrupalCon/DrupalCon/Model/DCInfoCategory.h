//
//  DCInfoCategory.h
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 12/19/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DCInfoCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * html;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * infoId;

@end
