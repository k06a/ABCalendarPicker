//
//  UIFastView.m
//  HNPCalendarPicker
//
//  Created by Антон Буков on 11.07.12.
//  Copyright (c) 2012 Happy Nation Project. All rights reserved.
//

#import "UIFastView.h"

@interface UIFastView()
@property (strong,nonatomic) NSMutableArray * array;
@end

@implementation UIFastView

@synthesize array = _array;

- (NSArray*)array
{
    if (_array == nil)
        _array = [NSMutableArray array];
    return _array;
}

- (void)addSubview:(UIView *)view
{
    [self.array addObject:view];
    //[super addSubview:view];
}

- (void)drawRect:(CGRect)rect
{
    /*for (UIButton * view in self.array)
    {
        view.layer.frame = view.frame;
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    */[super drawRect:rect];
}

@end
