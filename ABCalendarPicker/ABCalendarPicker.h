//
//  ABCalendarPicker.h
//  ABCalendarPicker
//
//  Created by Anton Bukov on 25.06.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABCalendarPickerDelegateProtocol.h"
#import "ABCalendarPickerDataSourceProtocol.h"
#import "ABCalendarPickerDateProviderProtocol.h"
#import "ABCalendarPickerStyleProviderProtocol.h"

// Need because of main library header
#import "ABCalendarPickerDefaultStyleProvider.h"
#import "ABCalendarPickerDefaultWeekdaysProvider.h"
#import "ABCalendarPickerDefaultTripleWeekdaysProvider.h"
#import "ABCalendarPickerDefaultDaysProvider.h"
#import "ABCalendarPickerDefaultMonthsProvider.h"
#import "ABCalendarPickerDefaultSeasonedMonthsProvider.h"
#import "ABCalendarPickerDefaultYearsProvider.h"
#import "ABCalendarPickerDefaultErasProvider.h"

/**
 
 This class implements calendar picker view, witch can be used several ways:
 
 - Asking user to choose concrete day/month/year
 - Allow user to navigate throw days/months/years hierarchy
 
 Hierarchy elements are represented by date providers, whitch are implementations of
 protocol `ABCalendarPickerDateProviderProtocol`. Calendar owns 5 date providers:
 weekdays, days, months, years, eras providers.
 
 */

@interface ABCalendarPicker : UIView<ABCalendarPickerDateOwner>

/// ----------------------------------------------------------------
/// @name Configuring behavior and displaying user data
/// ----------------------------------------------------------------

/** Delegate is needed for configuring and noticing calendars behavior. */
@property (assign,nonatomic) IBOutlet id<ABCalendarPickerDelegateProtocol> delegate;
/** Delegate is needed for displaying user information on calendar. */
@property (assign,nonatomic) IBOutlet id<ABCalendarPickerDataSourceProtocol> dataSource;
/** Flag means wich side of the view should grow: bottom or top. */
@property (nonatomic) BOOL bottomExpanding;
/** Flag means is swipe enabled for navigation. */
@property (nonatomic) BOOL swipeNavigationEnabled;

/// ----------------------------------------------------------------
/// @name Customization
/// ----------------------------------------------------------------

/** Provides styling, for subviews */
@property (strong,nonatomic) id<ABCalendarPickerStyleProviderProtocol> styleProvider;

/** Provides button layout, animations and other options for days in week view */
@property (strong,nonatomic) id<ABCalendarPickerDateProviderProtocol> weekdaysProvider;
/** Provides button layout, animations and other options for days in month view */
@property (strong,nonatomic) id<ABCalendarPickerDateProviderProtocol> daysProvider;
/** Provides button layout, animations and other options for months in year view */
@property (strong,nonatomic) id<ABCalendarPickerDateProviderProtocol> monthsProvider;
/** Provides button layout, animations and other options for years in eras view */
@property (strong,nonatomic) id<ABCalendarPickerDateProviderProtocol> yearsProvider;
/** Provides button layout, animations and other options for eras in xxx view */
@property (strong,nonatomic) id<ABCalendarPickerDateProviderProtocol> erasProvider;

/** Is used for all dates calculations during calendar navigation. Default value for
 calendar is `[NSCalendar currentCalendar]`, but you can assign any.
 
 For example, you can set first weekday to _monday_ this way:
 
    NSCalendar * calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];
    calendarPicker.calendar = calendar;
 */
@property (strong,nonatomic) NSCalendar * calendar;

/// ----------------------------------------------------------------
/// @name Accessing current state
/// ----------------------------------------------------------------

/** Retrieving current calendar state */
@property (readonly,nonatomic) ABCalendarPickerState currentState;
/** Retrieving and setting selected date, looks like today date. */
@property (readonly,strong,nonatomic) NSDate * selectedDate;
/** Retrieving and setting highlighted date, looks like user-tapped date. */
@property (readonly,strong,nonatomic) NSDate * highlightedDate;

- (void)updateStateAnimated:(BOOL)animated;

- (void)setDate:(NSDate*)date andState:(ABCalendarPickerState)state animated:(BOOL)animated;

- (void)setState:(ABCalendarPickerState)state animated:(BOOL)animated;

- (void)setSelectedDate:(NSDate *)date animated:(BOOL)animated;

- (void)setHighlightedAndSectedDate:(NSDate *)date animated:(BOOL)animated;

@end
