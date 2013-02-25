//
//  ABCalendarPickerDefaultWeekdaysProvider.h
//  CalendarPickerDemo
//
//  Created by Антон Буков on 06.07.12.
//
//

#import <Foundation/Foundation.h>
#import "ABCalendarPickerDateProviderProtocol.h"

@interface ABCalendarPickerDefaultWeekdaysProvider : NSObject<ABCalendarPickerDateProviderProtocol>

@property (weak,nonatomic) id<ABCalendarPickerDateOwner> dateOwner;

- (NSInteger)canDiffuse;

- (ABCalendarPickerAnimation)animationForPrev;
- (ABCalendarPickerAnimation)animationForNext;
- (ABCalendarPickerAnimation)animationForZoomInToProvider:(id<ABCalendarPickerDateProviderProtocol>)provider;
- (ABCalendarPickerAnimation)animationForZoomOutToProvider:(id<ABCalendarPickerDateProviderProtocol>)provider;

- (NSDate*)dateForPrevAnimation;
- (NSDate*)dateForNextAnimation;

- (NSInteger)rowsCount;
- (NSInteger)columnsCount;
- (NSString*)columnName:(NSInteger)column;
- (NSString*)titleText;

- (NSDate*)dateForRow:(NSInteger)row andColumn:(NSInteger)column;
- (NSString*)labelForDate:(NSDate*)date;
- (UIControlState)controlStateForDate:(NSDate*)date;
- (NSString*)labelForRow:(NSInteger)row andColumn:(NSInteger)column;
- (UIControlState)controlStateForRow:(NSInteger)row andColumn:(NSInteger)column;

@property (strong,nonatomic) NSCalendar * calendar;

@end
