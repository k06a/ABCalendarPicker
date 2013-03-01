//
//  ABCalendarPickerDefaultTripleWeekdaysProvider.m
//  ABCalendarPicker
//
//  Created by Anton Bukov on 22.02.13.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import "ABCalendarPickerDefaultTripleWeekdaysProvider.h"

@implementation ABCalendarPickerDefaultTripleWeekdaysProvider

/*
- (ABCalendarPickerAnimation)animationForZoomOutToProvider:(id<ABCalendarPickerDateProviderProtocol>)provider {
    NSDate * mainWeekBegin = [self dateForRow:(self.rowsCount/2 + 1) andColumn:0];
    NSDate * mainWeekEnd = [self dateForRow:(self.rowsCount/2 + 1) andColumn:6];
    
    int shift = 0;
    if ([[self.dateOwner highlightedDate] compare:mainWeekBegin] < 0)
        shift = -1;
    if ([[self.dateOwner highlightedDate] compare:mainWeekEnd] > 0)
        shift = 1;
    
    NSInteger weekNumber = [self.calendar ordinalityOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:[self.dateOwner highlightedDate]];
    return ABCalendarPickerAnimationScrollUpOrDownBase - (weekNumber + shift);
}
*/

- (NSInteger)rowsCount
{
    return 3;
}

- (NSInteger)canDiffuse
{
    return 2;
}

- (NSDate *)mainDateBegin
{
    return [self dateForRow:(self.rowsCount/2) andColumn:0];
}

- (NSDate *)mainDateEnd
{
    return [self dateForRow:(self.rowsCount/2) andColumn:6];
}

- (NSDate*)dateForRow:(NSInteger)row
            andColumn:(NSInteger)column
{
    return [super dateForRow:row-1 andColumn:column];
}

@end
