//
//  ABCalendarPickerDelegateProtocol.h
//  ABCalendarPicker
//
//  Created by Anton Bukov on 05.07.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABCalendarPicker;

typedef enum {
    ABCalendarPickerStateWeekdays = 1,
    ABCalendarPickerStateDays     = 2,
    ABCalendarPickerStateMonths   = 3,
    ABCalendarPickerStateYears    = 4,
    ABCalendarPickerStateEras     = 5,
} ABCalendarPickerState;

@protocol ABCalendarPickerDelegateProtocol
@optional
- (void)calendarPicker:(ABCalendarPicker*)calendarPicker
      animateNewHeight:(CGFloat)height;
- (BOOL)calendarPicker:(ABCalendarPicker*)calendarPicker
        shouldSetState:(ABCalendarPickerState)state
             fromState:(ABCalendarPickerState)fromState;
- (void)calendarPicker:(ABCalendarPicker*)calendarPicker
          willSetState:(ABCalendarPickerState)state
             fromState:(ABCalendarPickerState)fromState;
- (void)calendarPicker:(ABCalendarPicker*)calendarPicker
           didSetState:(ABCalendarPickerState)state
             fromState:(ABCalendarPickerState)fromState;
- (BOOL)calendarPicker:(ABCalendarPicker*)calendarPicker
       shoudSelectDate:(NSDate*)date
             withState:(ABCalendarPickerState)state;
- (void)calendarPicker:(ABCalendarPicker*)calendarPicker
          dateSelected:(NSDate*)date
             withState:(ABCalendarPickerState)state;
@end
