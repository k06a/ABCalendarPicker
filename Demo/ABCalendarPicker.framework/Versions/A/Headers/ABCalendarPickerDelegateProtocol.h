//
//  ABCalendarPickerDelegateProtocol.h
//  CalendarPickerDemo
//
//  Created by Антон Буков on 05.07.12.
//
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
- (void)calendarPicker:(ABCalendarPicker*)calendarPicker
          dateSelected:(NSDate*)date
             withState:(ABCalendarPickerState)state;
@end
