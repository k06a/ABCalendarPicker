//
//  ABInitializedObjectsQueue.h
//  ABCalendarPicker
//
//  Created by Anton Bukov on 05.07.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef id (^ObjectInitBlock)();

@interface ABViewPool : NSObject

- (UIView*)giveExistingOrCreateNewWith:(ObjectInitBlock)block;
- (void)clear;

@end
