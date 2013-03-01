//
//  ABCalendarPickerDataSourceProtocol.h
//  ABCalendarPicker
//
//  Created by Anton Bukov on 01.07.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABCalendarPickerDelegateProtocol.h"

@protocol ABCalendarPickerDataSourceProtocol

- (NSInteger)calendarPicker:(ABCalendarPicker *)calendarPicker
      numberOfEventsForDate:(NSDate *)date
                    onState:(ABCalendarPickerState)state;

@end
