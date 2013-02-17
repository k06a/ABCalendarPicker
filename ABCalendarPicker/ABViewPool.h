//
//  ABInitializedObjectsQueue.h
//  CalendarPickerDemo
//
//  Created by Антон Буков on 05.07.12.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef id (^ObjectInitBlock)();

@interface ABViewPool : NSObject

- (UIView*)giveExistingOrCreateNewWith:(ObjectInitBlock)block;
- (void)clear;

@end
