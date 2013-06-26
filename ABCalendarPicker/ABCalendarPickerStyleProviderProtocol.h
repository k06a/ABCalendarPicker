//
//  ABCalendarPickerStyleProviderProtocol.h
//  ABCalendarPicker
//
//  Created by Anton Bukov on 23.07.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol ABCalendarPickerStyleProviderProtocol <NSObject>

@property (strong,nonatomic) UIColor * textColor;
@property (strong,nonatomic) UIColor * textShadowColor;
@property (strong,nonatomic) UIImage * patternImageForGradientBar;

@property (strong,nonatomic) UIFont * titleFontForColumnTitlesVisible;
@property (strong,nonatomic) UIFont * titleFontForColumnTitlesInvisible;
@property (strong,nonatomic) UIFont * columnFont;
@property (strong,nonatomic) UIFont * tileTitleFont;
@property (strong,nonatomic) UIFont * tileDotFont;

- (UIControl*)calendarPicker:(ABCalendarPicker*)calendarPicker
            cellViewForTitle:(NSString*)cellTitle
                    andState:(ABCalendarPickerState)state;

- (void)calendarPicker:(ABCalendarPicker*)calendarPicker
 postUpdateForCellView:(UIControl*)control
        onControlState:(UIControlState)controlState
            withEvents:(NSInteger)eventsCount
              andState:(ABCalendarPickerState)state;

@end
