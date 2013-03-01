//
//  ABCalendarPickerDefaultSeasonedMonthProvider.m
//  ABCalendarPicker
//
//  Created by Anton Bukov on 28.06.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import "ABCalendarPickerDefaultSeasonedMonthsProvider.h"

@interface ABCalendarPickerDefaultSeasonedMonthsProvider()
@property (strong,nonatomic) NSDateFormatter * dateFormatter;
@end

@implementation ABCalendarPickerDefaultSeasonedMonthsProvider

@synthesize dateOwner = _dateOwner;
@synthesize calendar = _calendar;
@synthesize dateFormatter = _dateFormatter;

@synthesize winterLabel = _winterLabel;
@synthesize springLabel = _springLabel;
@synthesize summerLabel = _summerLabel;
@synthesize autumnLabel = _autumnLabel;

- (NSString*)winterLabel
{
    if (_winterLabel == nil)
        _winterLabel = [@"ru" isEqualToString:[[NSLocale preferredLanguages] objectAtIndex:0]] ? @"Зима" : @"Winter";
    return _winterLabel;
}

- (NSString*)springLabel
{
    if (_springLabel == nil)
        _springLabel = [@"ru" isEqualToString:[[NSLocale preferredLanguages] objectAtIndex:0]] ? @"Весна" : @"Spring";
    return _springLabel;
}

- (NSString*)summerLabel
{
    if (_summerLabel == nil)
        _summerLabel = [@"ru" isEqualToString:[[NSLocale preferredLanguages] objectAtIndex:0]] ? @"Лето" : @"Summer";
    return _summerLabel;
}

- (NSString*)autumnLabel
{
    if (_autumnLabel == nil)
        _autumnLabel = [@"ru" isEqualToString:[[NSLocale preferredLanguages] objectAtIndex:0]] ? @"Осень" : @"Autumn";
    return _autumnLabel;
}

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
    return 1;
}

- (NSDate *)mainDateBegin
{
    return [self dateForRow:1 andColumn:0];
}

- (NSDate *)mainDateEnd
{
    return [self dateForRow:0 andColumn:4];
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
    return 5;
}

- (NSString*)columnName:(NSInteger)column
{
    NSArray * array = [NSArray arrayWithObjects:self.winterLabel, self.springLabel, self.summerLabel, self.autumnLabel, self.winterLabel, nil];
    return [array objectAtIndex:column];
}

- (NSString*)titleText
{
    NSInteger year = [self.calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:[self.dateOwner highlightedDate]];
    return [NSString stringWithFormat:@"%d",year,nil];
}

- (NSDate*)dateForRow:(NSInteger)row 
            andColumn:(NSInteger)column 
{
    NSInteger index = column*[self rowsCount] + row;
    NSInteger month = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:[self.dateOwner highlightedDate]];
    
    NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = index - month;
    return [self.calendar dateByAddingComponents:dateComponents toDate:[self.dateOwner highlightedDate] options:0];
}

- (NSString*)labelForDate:(NSDate*)date
{
    //NSInteger month = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:date];
    //NSString * name = [[self.dateFormatter shortStandaloneMonthSymbols] objectAtIndex:month-1];
    //if ([name characterAtIndex:name.length-1] == '.')
    //    return [name substringToIndex:name.length-1];
    //return name;
    [self.dateFormatter setDateFormat:@"LLL"];
    NSString * str = [self.dateFormatter stringFromDate:date];
    return [str substringToIndex:MIN(3,str.length)];
}

- (UIControlState)controlStateForDate:(NSDate*)date
{
    NSInteger currentYear = [self.calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:date];
    NSInteger selectedYear = [self.calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:[self.dateOwner selectedDate]];
    NSInteger highlightedYear = [self.calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:[self.dateOwner highlightedDate]];
    
    if (currentYear != highlightedYear)
        return UIControlStateDisabled;

    NSInteger currentMonth = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:date];
    NSInteger selectedMonth = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:[self.dateOwner selectedDate]];
    NSInteger highlightedMonth = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:[self.dateOwner highlightedDate]];
    
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
