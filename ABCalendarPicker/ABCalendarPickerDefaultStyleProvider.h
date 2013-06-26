//
//  ABCalendarPickerDefaultStyleProvider.h
//  ABCalendarPicker
//
//  Created by Anton Bukov on 01.07.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import "ABCalendarPicker.h"
#import "ABCalendarPickerStyleProviderProtocol.h"
#import <Foundation/Foundation.h>

@interface ABCalendarPickerDefaultStyleProvider : NSObject<ABCalendarPickerStyleProviderProtocol>

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

@property (strong,nonatomic) UIImage * normalImage;
@property (strong,nonatomic) UIImage * selectedImage;
@property (strong,nonatomic) UIImage * highlightedImage;
@property (strong,nonatomic) UIImage * selectedHighlightedImage;

@property (strong,nonatomic) UIColor * normalTextColor;
@property (strong,nonatomic) UIColor * disabledTextColor;
@property (strong,nonatomic) UIColor * selectedTextColor;

@property (strong,nonatomic) UIColor * normalTextShadowColor;
@property (strong,nonatomic) UIColor * disabledTextShadowColor;
@property (strong,nonatomic) UIColor * selectedTextShadowColor;

@property (assign,nonatomic) CGSize normalTextShadowPosition;
@property (assign,nonatomic) CGSize disabledTextShadowPosition;
@property (assign,nonatomic) CGSize selectedTextShadowPosition;

@property (assign,nonatomic) NSInteger maxNumberOfDots;

@end
