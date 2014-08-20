//
//  DCProgramsDataSourceMananger.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCProgramsDataSourceMananger.h"
#import "DCTestContentGenerator.h"


@interface DCProgramsDataSourceMananger()
@property (nonatomic, strong) NSArray *program;
@end

@implementation DCProgramsDataSourceMananger

+(instancetype)shared
{
    static DCProgramsDataSourceMananger * _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[DCProgramsDataSourceMananger alloc] init];
    });
    
    return _sharedInstance;
}

-(id) init {
    self = [super init];
    self.program = [DCTestContentGenerator simulateConferenceItems];
    return self;
}

/* yup, seems a bit complicated, if you take a look ar DCProgramDatasourceMaanger you'll understand how the items(events) are grouped by time periods*/
-(DCEvent*) eventForSection: (int) section row: (int) row inDay: (int)day{
    return ((self.program[day])[@"ranges"])[section][@"events"][row];
}

-(NSUInteger) days {
    return [self.program count];
}

-(NSUInteger) sectionsInDay: (int) day {
    return [(self.program[day])[@"ranges"] count];
}

-(NSUInteger) itemsInDay: (int) day inSection: (int) section {
    return [((self.program[day])[@"ranges"])[section][@"events"] count];
}

-(NSDictionary*) dictionaryContatiningRangeAndArrayOfEventsInDay: (int) day section: (int) section {
    return ((self.program[day])[@"ranges"])[section];
}

-(NSDictionary*) dictionaryForDay: (int) day {
    return self.program[day];
}


@end
