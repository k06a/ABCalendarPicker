//
//  ABCalendarPickerDefaultStyleProvider.h
//  ABCalendarPicker
//
//  Created by Антон Буков on 23.07.12.
//  Copyright (c) 2012 Happy Nation Project. All rights reserved.
//

#import "ABCalendarPicker.h"
#import "ABCalendarPickerStyleProviderProtocol.h"
#import <Foundation/Foundation.h>

@interface ABCalendarPickerDefaultStyleProvider : NSObject<ABCalendarPickerStyleProviderProtocol>

@property (readonly,nonatomic) UIColor * textColor;
@property (readonly,nonatomic) UIColor * textShadowColor;

- (UIControl*)calendarPicker:(ABCalendarPicker*)calendarPicker
            cellViewForTitle:(NSString*)cellTitle
                    andState:(ABCalendarPickerState)state;

- (void)calendarPicker:(ABCalendarPicker*)calendarPicker
 postUpdateForCellView:(UIControl*)control
        onControlState:(UIControlState)controlState
            withEvents:(NSInteger)eventsCount
              andState:(ABCalendarPickerState)state;

@property (nonatomic) UIImage * patternImageForGradientBar;

@property (nonatomic) UIImage * normalImage;
@property (nonatomic) UIImage * selectedImage;
@property (nonatomic) UIImage * highlightedImage;
@property (nonatomic) UIImage * selectedHighlightedImage;

@property (nonatomic) UIColor * normalTextColor;
@property (nonatomic) UIColor * disabledTextColor;
@property (nonatomic) UIColor * selectedTextColor;

@property (nonatomic) UIColor * normalTextShadowColor;
@property (nonatomic) UIColor * disabledTextShadowColor;
@property (nonatomic) UIColor * selectedTextShadowColor;

@property (nonatomic) CGSize normalTextShadowPosition;
@property (nonatomic) CGSize disabledTextShadowPosition;
@property (nonatomic) CGSize selectedTextShadowPosition;

@property (nonatomic) NSInteger maxNumberOfDots;

@end
