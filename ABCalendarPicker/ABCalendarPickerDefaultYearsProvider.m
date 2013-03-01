//
//  ABCalendarPickerDefaultYearsProvider.m
//  ABCalendarPicker
//
//  Created by Anton Bukov on 29.06.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import "ABCalendarPickerDefaultYearsProvider.h"

@interface ABCalendarPickerDefaultYearsProvider()
@end

@implementation ABCalendarPickerDefaultYearsProvider

@synthesize dateOwner = _dateOwner;
@synthesize calendar = _calendar;

- (id)init
{
    if (self = [super init])
        self.calendar = [NSCalendar currentCalendar];
    return self;
}

- (NSInteger)canDiffuse
{
    return NO;
}

- (ABCalendarPickerAnimation)animationForPrev {
    return ABCalendarPickerAnimationScrollLeft;
}
- (ABCalendarPickerAnimation)animationForNext {
    return ABCalendarPickerAnimationScrollRight;
}
- (ABCalendarPickerAnimation)animationForZoomInToProvider:(id<ABCalendarPickerDateProviderProtocol>)provider {
    return ABCalendarPickerAnimationZoomIn;
}
- (ABCalendarPickerAnimation)animationForZoomOutToProvider:(id<ABCalendarPickerDateProviderProtocol>)provider {
    return ABCalendarPickerAnimationZoomOut;
}

- (NSDate*)dateForPrevAnimation
{
    NSDateComponents * components = [[NSDateComponents alloc] init];
    components.year = -[self rowsCount]*[self columnsCount];
    return [self.calendar dateByAddingComponents:components toDate:[self.dateOwner highlightedDate] options:0];   
}

- (NSDate*)dateForNextAnimation
{
    NSDateComponents * components = [[NSDateComponents alloc] init];
    components.year = [self rowsCount]*[self columnsCount];
    return [self.calendar dateByAddingComponents:components toDate:[self.dateOwner highlightedDate] options:0]; 
}

- (NSInteger)rowsCount
{
    return 4;
}

- (NSInteger)columnsCount
{
    return 5;
}

- (NSString*)columnName:(NSInteger)column
{
    return nil;
}

- (NSString*)titleText
{
    NSDate * firstDate = [self dateForRow:0 andColumn:0];
    NSInteger firstYear = [self.calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:firstDate];
    NSInteger lastYear = firstYear + [self rowsCount]*[self columnsCount] - 1;
    return [NSString stringWithFormat:@"%d - %d", firstYear, lastYear, nil];
}

- (NSDate*)dateForRow:(NSInteger)row
            andColumn:(NSInteger)column 
{
    NSInteger components = (NSEraCalendarUnit
                            | NSYearCalendarUnit 
                            | NSMonthCalendarUnit 
                            | NSDayCalendarUnit);
    
    NSDateComponents * dateComponents = [self.calendar components:components fromDate:[self.dateOwner highlightedDate]];
    NSInteger yearOffset = (dateComponents.year - 1) / ([self rowsCount]*[self columnsCount])
                                                     * ([self rowsCount]*[self columnsCount]);
    dateComponents.year = yearOffset + row*[self columnsCount]+column + 1;
    return [self.calendar dateFromComponents:dateComponents];
}

- (NSString*)labelForDate:(NSDate*)date
{
    NSInteger year = [self.calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:date];
    return [NSString stringWithFormat:@"%d",year,nil];
}

- (UIControlState)controlStateForDate:(NSDate*)date
{
    NSUInteger currentYear = [self.calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:date];
    NSUInteger selectedYear = [self.calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:[self.dateOwner selectedDate]];
    NSUInteger highlightedYear = [self.calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:[self.dateOwner highlightedDate]];
    
    BOOL isSelected = (currentYear == selectedYear);
    BOOL isHilighted = (currentYear == highlightedYear); 
    if (isSelected || isHilighted)
        return (isSelected ? UIControlStateSelected : 0) | (isHilighted ? UIControlStateHighlighted : 0);
    
    return UIControlStateNormal;
}

- (NSString*)labelForRow:(NSInteger)row 
               andColumn:(NSInteger)column                  
{
    return [self labelForDate:[self dateForRow:row andColumn:column]];
}

- (UIControlState)controlStateForRow:(NSInteger)row 
                           andColumn:(NSInteger)column 
{
    return [self controlStateForDate:[self dateForRow:row andColumn:column]];
}

@end
