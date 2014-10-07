//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
    return (int)[self.sectionsItems count];
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
    return (int)[events count];
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

- (DCEvent *)eventForIndexPath:(NSIndexPath *)indexPath
{
    return [self DC_eventForIndexPath:indexPath];
}


- (DCEvent*)DC_eventForIndexPath:(NSIndexPath *)indexPath
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
