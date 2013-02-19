//
//  main.m
//  ABCalendarPickerDemo
//
//  Created by Антон Буков on 19.02.13.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ABCalendarPicker/ABCalendarPicker.h>

#import "ABAppDelegate.h"

int main(int argc, char *argv[])
{
    [ABCalendarPicker class];
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([ABAppDelegate class]));
    }
}
