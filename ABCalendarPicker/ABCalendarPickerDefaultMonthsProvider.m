//
//  ABCalendarPickerDefaultMonthsProvider.m
//  ABCalendarPicker
//
//  Created by Anton Bukov on 27.06.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import "ABCalendarPickerDefaultMonthsProvider.h"

@interface ABCalendarPickerDefaultMonthsProvider()
@property (strong,nonatomic) NSDateFormatter * dateFormatter;
@end

@implementation ABCalendarPickerDefaultMonthsProvider

@synthesize dateOwner = _dateOwner;
@synthesize calendar = _calendar;
@synthesize dateFormatter = _dateFormatter;

- (id)init
{
    if (self = [super init])
    {
        self.calendar = [NSCalendar currentCalendar];
        self.dateFormatter = [[NSDateFormatter alloc] init];
    }
    return self;
}

- (NSInteger)canDiffuse
{
    return 0;
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
    components.year = -1;
    return [self.calendar dateByAddingComponents:components toDate:[self.dateOwner highlightedDate] options:0];   
}

- (NSDate*)dateForNextAnimation
{
    NSDateComponents * components = [[NSDateComponents alloc] init];
    components.year = 1;
    return [self.calendar dateByAddingComponents:components toDate:[self.dateOwner highlightedDate] options:0]; 
}

- (NSInteger)rowsCount
{
    return 3;
}

- (NSInteger)columnsCount
{
    return 4;
}

- (NSString*)columnName:(NSInteger)column
{
    return nil;
}

- (NSString*)titleText
{
    self.dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyy" options:0 locale:[NSLocale currentLocale]];
    return [self.dateFormatter stringFromDate:[self.dateOwner highlightedDate]];
}

- (NSDate*)dateForRow:(NSInteger)row 
            andColumn:(NSInteger)column 
{
    NSInteger index = column*[self rowsCount] + row + 1;
    NSInteger month = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:[self.dateOwner highlightedDate]];
    
    NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = index - month;
    return [self.calendar dateByAddingComponents:dateComponents toDate:[self.dateOwner highlightedDate] options:0];
}

- (NSString*)labelForDate:(NSDate*)date
{
    [self.dateFormatter setDateFormat:@"LLL"];
    NSString * str = [self.dateFormatter stringFromDate:date];
    return [str substringToIndex:MIN(3,str.length)];
}

- (UIControlState)controlStateForDate:(NSDate*)date
{
    NSInteger currentMonth = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:date];
    NSInteger selectedMonth = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:[self.dateOwner selectedDate]];
    NSInteger highlightedMonth = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:[self.dateOwner highlightedDate]];
    NSInteger selectedYear = [self.calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:[self.dateOwner selectedDate]];
    NSInteger highlightedYear = [self.calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:[self.dateOwner highlightedDate]];
    
    BOOL isSelected = (currentMonth == selectedMonth) && (highlightedYear == selectedYear);
    BOOL isHilighted = (currentMonth == highlightedMonth); 
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
