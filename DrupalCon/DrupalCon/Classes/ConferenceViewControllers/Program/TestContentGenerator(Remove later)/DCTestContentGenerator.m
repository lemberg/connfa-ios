//
//  DCTestContentGenerator.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Rostyslav Stepanyak. All rights reserved.
//

#import "DCTestContentGenerator.h"
#import "DCEvent.h"
#import "DCTimeRangeForGrouper.h"

@implementation DCTestContentGenerator

+(NSArray*) simulateConferenceItems {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"conference" ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *conferenceItems = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSMutableArray *arrayOfDaysInConference = [[NSMutableArray alloc] init];
    
    NSArray *days = conferenceItems[@"days"];
    for(NSDictionary *day in days) {
        
        NSMutableDictionary *_day = [[NSMutableDictionary alloc] init];
        [_day setObject: day[@"date"] forKey: @"date"];
        
        NSMutableArray *itemsInDay = [[NSMutableArray alloc] init];
        for(NSDictionary *item in day[@"events"]) {
            DCEvent *event = [[DCEvent alloc] init];
            event.time = [[DCTimeRange alloc] init];
            event.eventType = [item[@"type"] intValue];
            event.time.from = item[@"from"];
            event.time.to = item[@"to"];
            event.name = item[@"name"];
            event.speaker = item[@"speaker"];
            event.track = item[@"track"];
            event.experienceLevel = item[@"experience_level"];
            [itemsInDay addObject: event];
        }
        [_day setObject: itemsInDay  forKey: @"events"];
        [arrayOfDaysInConference addObject: _day];
    }
    return [DCTestContentGenerator group: arrayOfDaysInConference];
}

/*We got array of days, all items in a specific day are not grouped, Lets group the days sorting by period, for example: 10:00 - 11: 55 will contain three speecges, 11:55 - 12:30 will contain two speaches, and so on*/

+(NSArray*) group: (NSMutableArray*) arrayOfDaysInConference {
    

    NSMutableArray *timeRanges = [[NSMutableArray alloc] init];
    //lets coolect all the ranges
    
    NSMutableArray *groupedDaysInConference = [[NSMutableArray alloc] init];
    
    for(NSDictionary *day in arrayOfDaysInConference) {
        for(DCEvent *item in day[@"events"]) {
            [timeRanges addObject: [[DCTimeRangeForGrouper alloc] initWithFrom:item.time.from to: item.time.to]];
        }
        
        NSArray *uniqueRanges = [timeRanges valueForKeyPath:@"@distinctUnionOfObjects.state"];
        uniqueRanges = [uniqueRanges sortedArrayUsingFunction:compare context:NULL];
        
        NSMutableDictionary *dateDict = [[NSMutableDictionary alloc] init];
        [dateDict setObject: day[@"date"] forKey: @"date"];
        
        
        NSMutableArray *ranges = [[NSMutableArray alloc] init];
        for(NSString *range in uniqueRanges) {
            for(DCEvent *item in day[@"events"]) {
                
                DCTimeRangeForGrouper *r = [[DCTimeRangeForGrouper alloc] initWithFrom:item.time.from to: item.time.to];
                
                DCTimeRangeForGrouper *_range = [[DCTimeRangeForGrouper alloc] initWithText: range];
                
                if([r.from isEqualToString: _range.from ] && [r.to isEqualToString: _range.to]) {
                    NSMutableDictionary *rangeDict = [DCTestContentGenerator findDictForRange: r inArray: ranges];
                    [rangeDict[@"events"] addObject: item];
                }
            }
        }
        [dateDict setObject: ranges forKey: @"ranges"];
        [groupedDaysInConference addObject: dateDict];
    }
    
    return groupedDaysInConference;

}

NSInteger compare(id obj1, id obj2, void* context) {
    float startHour = [[[(NSString*)obj1 componentsSeparatedByString:@"-"] objectAtIndex:0] floatValue];
    float startMinutes = [[[(NSString*)obj1 componentsSeparatedByString:@"-"] objectAtIndex:1] floatValue];
    startHour += (startMinutes / 60.0);
    
    float endHour = [[[(NSString*)obj2 componentsSeparatedByString:@"-"] objectAtIndex:0] floatValue];
    float endMinutes = [[[(NSString*)obj2 componentsSeparatedByString:@"-"] objectAtIndex:1] floatValue];
    endHour += (endMinutes / 60.0);
    
    return startHour > endHour;
}

+(NSMutableDictionary*) findDictForRange: (DCTimeRangeForGrouper*) range inArray: (NSMutableArray*) array {
    
    for(NSMutableDictionary *rangeDict in array) {
        if([rangeDict[@"from"] isEqualToString: range.from ] && [rangeDict[@"to"] isEqualToString: range.to]) {
            return rangeDict;
        }
    }
    
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
    [newDict setObject:  range.from forKey: @"from"];
    [newDict setObject:  range.to forKey: @"to"];
    [newDict setObject: [[NSMutableArray alloc] init] forKey: @"events"];
    [array addObject: newDict];
    
    return newDict;
}

@end
