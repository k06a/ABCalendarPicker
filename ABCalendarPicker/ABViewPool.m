//
//  ABInitializedObjectsQueue.m
//  ABCalendarPicker
//
//  Created by Anton Bukov on 05.07.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import "ABViewPool.h"

@interface ABViewPool()
@property (strong,nonatomic) NSMutableArray * objects;
@property (nonatomic) NSInteger beginIndex;
@end

@implementation ABViewPool

@synthesize objects = _objects;
@synthesize beginIndex = _beginIndex;

- (NSMutableArray*)objects
{
    if (_objects == nil)
        _objects = [NSMutableArray new];
    return _objects;
}

- (UIView*)giveExistingOrCreateNewWith:(ObjectInitBlock)block
{
    for (int i = 0; i < self.objects.count; i++)
    {
        NSInteger index = (self.beginIndex + i) % self.objects.count;
        UIView * object = [self.objects objectAtIndex:index];
        if (object.superview == nil)
        {
            self.beginIndex = (i + 1) % self.objects.count;
            return object;
        }
    }
    
    UIView * object = block();
    [self.objects addObject:object];
    return object;
}

- (void)clear
{
    self.objects = [NSMutableArray new];
}

@end
