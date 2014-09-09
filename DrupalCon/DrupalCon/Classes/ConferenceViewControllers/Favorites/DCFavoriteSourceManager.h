//
//  DCFavoriteManager.h
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/5/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DCEvent, DCTimeRange;

@interface DCFavoriteSourceManager : NSObject

- (id)initWithSection:(NSArray *)newSections;
- (DCEvent *)eventForIndexPath:(NSIndexPath *)indexPath;
- (int)numberOfSection;
- (int)numberOfEventsInSection:(int)aSection;
- (DCTimeRange *)timeRangeForSection:(int)aSection;
- (NSString *)dateForSection:(int)aSection;
- (void)deleteEventsAtIndexPath:(NSIndexPath *)anIndexPath;
- (void)deleteSectionAtIndex:(int)anIndex;
@end
