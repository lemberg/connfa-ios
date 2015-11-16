//
//  DCInfo.h
//  DrupalCon
//
//  Created by Olexandr on 4/7/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCInfoCategory;

@interface DCInfo : NSManagedObject

@property(nonatomic, retain) NSString* titleMajor;
@property(nonatomic, retain) NSString* titleMinor;
@property(nonatomic, retain) NSSet* infoCategory;
@end

@interface DCInfo (CoreDataGeneratedAccessors)

- (void)addInfoCategoryObject:(DCInfoCategory*)value;
- (void)removeInfoCategoryObject:(DCInfoCategory*)value;
- (void)addInfoCategory:(NSSet*)values;
- (void)removeInfoCategory:(NSSet*)values;

@end
