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

#import "DCEventStrategy.h"
#import "DCMainProxy+Additions.h"

@interface DCEventStrategy ()

@property (nonatomic, strong) Class eventClass;

@end

@implementation DCEventStrategy

- (instancetype)initWithStrategy:(EDCEventStrategy)strategy
{
    self = [super init];
    if (self)
    {
        _strategy = strategy;
        switch (_strategy)
        {
            case EDCEventStrategyPrograms:
                _eventClass = [DCProgram class];
                break;
                
            case EDCEventStrategyBofs:
                _eventClass = [DCBof class];
                break;
                
            default:
                break;
        }
    }
    return self;
}

- (NSArray*)days
{
    return [[DCMainProxy sharedProxy] daysForClass:_eventClass];
}

- (NSArray*)eventsForDayNum:(NSInteger)dayNumber
{
    return [[DCMainProxy sharedProxy] eventsForDayNum:dayNumber forClass:_eventClass];
}

- (NSArray*)uniqueTimeRangesForDayNum:(NSInteger)dayNumber
{
    return [[DCMainProxy sharedProxy] uniqueTimeRangesForDayNum:dayNumber forClass:_eventClass];
}

@end
