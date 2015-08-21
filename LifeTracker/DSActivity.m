//
//  DSActivity.m
//  LifeTracker
//
//  Created by Daniel Salowe on 4/8/14.
//  Copyright (c) 2014 Danny Salowe. All rights reserved.
//

#import "DSActivity.h"

@implementation DSActivity

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [self init]) {
        _name = [decoder decodeObjectForKey:@"name"];
        _type = [decoder decodeObjectForKey:@"type"];
        _time = [decoder decodeObjectForKey:@"time"];
        _aboveBelow = [decoder decodeObjectForKey:@"aboveBelow"];
        _date = [decoder decodeObjectForKey:@"date"];
        _startTime = [decoder decodeObjectForKey:@"startTime"];
        _endTime = [decoder decodeObjectForKey:@"endTime"];
        _timeElasped = [decoder decodeObjectForKey:@"timeElasped"];
        _completed = [decoder decodeObjectForKey:@"completed"];
        _longitude = [decoder decodeObjectForKey:@"longitude"];
        _longitude = [decoder decodeObjectForKey:@"latitude"];
        _previousDays = [decoder decodeObjectForKey:@"previousDays"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_type forKey:@"type"];
    [coder encodeObject:_time forKey:@"time"];
    [coder encodeObject:_aboveBelow forKey:@"aboveBelow"];
    [coder encodeObject:_date forKey:@"date"];
    [coder encodeObject:_startTime forKey:@"startTime"];
    [coder encodeObject:_endTime forKey:@"endTime"];
    [coder encodeObject:_timeElasped forKey:@"timeElasped"];
    [coder encodeObject:_completed forKey:@"completed"];
    [coder encodeObject:_longitude forKey:@"longitude"];
    [coder encodeObject:_longitude forKey:@"latitude"];
    [coder encodeObject:_previousDays forKey:@"previousDays"];

}


@end
