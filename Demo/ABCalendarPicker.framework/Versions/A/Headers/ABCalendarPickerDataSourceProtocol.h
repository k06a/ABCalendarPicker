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

- (NSArray*)calendarPicker:(ABCalendarPicker*)calendarPicker
             eventsForDate:(NSDate*)date
                   onState:(ABCalendarPickerState)state;

@end
