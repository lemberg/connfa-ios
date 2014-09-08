//
//  DCFavoriteManager.m
//  DrupalCon
//
//  Created by Olexandr Poburynnyi on 9/5/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCFavoriteSourceManager.h"
#import "DCTimeRange+DC.h"
#import "NSArray+DC.h"
#import "DCEvent.h"

@interface DCFavoriteSourceManager ()
@property (nonatomic, strong) NSMutableArray *sectionsItems;
@end


@implementation DCFavoriteSourceManager

static NSString * const kUniqueSections = @"sections";
static NSString * const kEventSections = @"events";
static NSString * const kTimeSection = @"time";

- (id)initWithSection:(NSArray *)newSections
{
    if (self = [super init]) {
        [self updateWithSection:newSections];
    }
    return self;
}

- (void)updateWithSection:(NSArray *)newSections
{
    [self loadSectionInfoFromCurrentSections:(NSArray *)newSections];
}

- (int)numberOfSection
{
    return [self.sectionsItems count];
}

- (DCTimeRange *)timeRangeForSection:(int)aSection
{
    return (DCTimeRange *)self.sectionsItems[aSection][kTimeSection];
}

- (NSString *)dateForSection:(int)aSection
{
    NSArray *events= self.sectionsItems[aSection][kEventSections];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM"];
    DCEvent *program = [events firstObject];
    return [dateFormat stringFromDate:[program date]];
}

- (int)numberOfEventsInSection:(int)aSection
{
    NSArray *events = self.sectionsItems[aSection][kEventSections];
    return [events count];
}

// Create special structure for favorite events ordering by date
// Each object is dictionary wich has time range for events and events according to this time
- (void)loadSectionInfoFromCurrentSections:(NSArray *)newSections
{
    NSMutableArray *sectionList = [NSMutableArray array];
    for (NSDictionary *section in newSections) {
        NSArray *sections = ((NSArray *)section[kUniqueSections]);
        NSArray *events = ((NSArray *)section[kEventSections]);
        for (DCTimeRange *timeRange in sections) {
            NSMutableDictionary *favoriteEvents = [NSMutableDictionary dictionary];
            NSMutableArray *eventsOfTimeRange = [[events eventsForTimeRange:timeRange] mutableCopy];
            [favoriteEvents setObject:timeRange forKey:kTimeSection];
            [favoriteEvents setObject:eventsOfTimeRange forKey:kEventSections];
            [sectionList addObject:favoriteEvents];
        }
        
    }
    
    self.sectionsItems = sectionList;
}

- (DCProgram *)eventForIndexPath:(NSIndexPath *)indexPath
{
    return [self DC_eventForIndexPath:indexPath];
}


- (DCProgram*)DC_eventForIndexPath:(NSIndexPath *)indexPath
{
    return self.sectionsItems[indexPath.section][kEventSections][indexPath.row];
}

- (void)deleteEventsAtIndexPath:(NSIndexPath *)atIndex
{
    NSMutableArray *events = self.sectionsItems[atIndex.section][kEventSections];
    [events removeObjectAtIndex:atIndex.row];
}

- (void)deleteSectionAtIndex:(int)anIndex
{
    [self.sectionsItems removeObjectAtIndex:anIndex];
}


@end
