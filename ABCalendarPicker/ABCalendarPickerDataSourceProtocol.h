//
//  ABCalendarPickerDataSourceProtocol.h
//  CalendarPickerDemo
//
//  Created by Антон Буков on 05.07.12.
//
//

#import <Foundation/Foundation.h>
#import "ABCalendarPickerDelegateProtocol.h"

@protocol ABCalendarPickerDataSourceProtocol

- (NSInteger)calendarPicker:(ABCalendarPicker *)calendarPicker
      numberOfEventsForDate:(NSDate *)date
                    onState:(ABCalendarPickerState)state;

@end
