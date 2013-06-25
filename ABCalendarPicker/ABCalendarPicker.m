//
//  ABCalendarPicker.m
//  ABCalendarPicker
//
//  Created by Anton Bukov on 25.06.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/QuartzCore.h>
#import "ABViewPool.h"
#import "ABCalendarPicker.h"

#define UP_ARROW_STRING @"▲"
#define DOWN_ARROW_STRING @"▼"
#define LEFT_ARROW_STRING @"◀"
#define RIGHT_ARROW_STRING @"▶"

@interface ABCalendarPicker()
@property (strong,nonatomic) NSMutableArray * controls;
@property (strong,nonatomic) NSMutableArray * columnLabels;
@property (strong,nonatomic) UILabel * titleLabel;
@property (strong,nonatomic) UIButton * titleButton;
@property (strong,nonatomic) UIButton * leftArrow;
@property (strong,nonatomic) UIButton * rightArrow;
@property (strong,nonatomic) UIButton * longLeftArrow;
@property (strong,nonatomic) UIButton * longRightArrow;
@property (strong,nonatomic) UIView * mainTileView;
@property (strong,nonatomic) UIView * oldTileView;
@property (strong,nonatomic) UIView * nowTileView;
@property (strong,nonatomic) UIImageView * fromImageView;
@property (strong,nonatomic) UIImageView * toImageView;
@property (strong,nonatomic) UIControl * highlightedControl;
@property (strong,nonatomic) UIControl * selectedControl;
@property (weak,nonatomic) UIControl * controlTouchBegin;
@property (readonly) NSArray * providers;
@property (nonatomic) ABCalendarPickerState previousState;
@property (strong,nonatomic) ABViewPool * buttonsPool;
@property (strong,nonatomic) NSMutableArray * dotLabels;
@property (nonatomic) NSInteger dotLabelsToRemove;
@property (nonatomic) BOOL deepPressingInProgress;

@property (nonatomic) ABCalendarPickerState currentState;
@property (strong,nonatomic) NSDate * selectedDate;
@property (strong,nonatomic) NSDate * highlightedDate;

@property (strong,nonatomic) UIImage * patternImage;
@property (strong,nonatomic) UIImage * normalImage;
@property (strong,nonatomic) UIImage * highlightedImage;
@property (strong,nonatomic) UIImage * selectedImage;
@property (strong,nonatomic) UIImage * selectedHighlightedImage;
@property (strong,nonatomic) UIImageView * gradientBar;

- (void)changeStateTo:(ABCalendarPickerState)toState
            fromState:(ABCalendarPickerState)fromState
            animation:(ABCalendarPickerAnimation)animation
           canDiffuse:(NSInteger)canDiffuse;
@end

@implementation ABCalendarPicker

@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize styleProvider = _styleProvider;
@synthesize weekdaysProvider = _weekdaysProvider;
@synthesize daysProvider = _daysProvider;
@synthesize monthsProvider = _monthsProvider;
@synthesize yearsProvider = _yearsProvider;
@synthesize erasProvider = _erasProvider;

@synthesize currentState = _currentState;
@synthesize selectedDate = _selectedDate;
@synthesize highlightedDate = _highlightedDate;
@synthesize calendar = _calendar;
@synthesize bottomExpanding = _bottomExpanding;
@synthesize swipeNavigationEnabled = _swipeNavigationEnabled;

@synthesize controls = _controls;
@synthesize columnLabels = _columnLabels;
@synthesize titleLabel = _titleLabel;
@synthesize titleButton = _titleButton;
@synthesize leftArrow = _leftArrow;
@synthesize rightArrow = _rightArrow;
@synthesize longLeftArrow = _longLeftArrow;
@synthesize longRightArrow = _longRightArrow;
@synthesize mainTileView = _mainTileView;
@synthesize oldTileView = _oldTileView;
@synthesize nowTileView = _nowTileView;
@synthesize fromImageView = _fromImageView;
@synthesize toImageView = _toImageView;
@synthesize selectedControl = _selectedControl;
@synthesize highlightedControl = _highlightedControl;
@synthesize controlTouchBegin = _buttonTouchBegin;
@synthesize previousState = _previousState;
@synthesize buttonsPool = _buttonsPool;
@synthesize dotLabels = _dotLabels;
@synthesize dotLabelsToRemove = _dotLabelsToRemove;
@synthesize deepPressingInProgress = _deepPressingInProgress;

@synthesize patternImage = _patternImage;
@synthesize normalImage = _normalImage;
@synthesize highlightedImage = _highlightedImage;
@synthesize selectedImage = _selectedImage;
@synthesize selectedHighlightedImage = _selectedHighlightedImage;
@synthesize gradientBar = _gradientBar;

- (NSBundle *)frameworkBundle
{
    static NSBundle * frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString * mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString * frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"ABCalendarPicker.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}

- (UIImage *)imageNamed:(NSString*)name
{
    if ([self frameworkBundle])
        return [UIImage imageWithContentsOfFile:[[self frameworkBundle] pathForResource:name ofType:@"png"]];
    else
        return [UIImage imageNamed:name];
}

#pragma mark -
#pragma mark Properties Implementations

- (void)setDataSource:(id<ABCalendarPickerDataSourceProtocol>)dataSource
{
    _dataSource = dataSource;
    if (self.superview)
        [self updateStateAnimated:NO];
}

- (void)setHighlightedDate:(NSDate *)highlightedDate
{
    NSTimeInterval interval = highlightedDate.timeIntervalSince1970;
    interval -= fmod(interval, 60);
    highlightedDate = [NSDate dateWithTimeIntervalSince1970:interval];
    
    if ([(id)self.delegate respondsToSelector:@selector(calendarPicker:shoudSelectDate:withState:)])
    {
        if (![(id)self.delegate calendarPicker:self
                               shoudSelectDate:highlightedDate
                                     withState:self.currentState])
        {
            return;
        }
    }
    
    _highlightedDate = highlightedDate;
    
    if ([self providerForState:self.currentState] != nil)
        [self updateTitleForProvider:[self providerForState:self.currentState]];
    
    //if (self.currentState == ABCalendarPickerStateDays
    //    || self.currentState == ABCalendarPickerStateWeekdays)
    //{
        if ([(id)self.delegate respondsToSelector:@selector(calendarPicker:dateSelected:withState:)])
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.delegate calendarPicker:self dateSelected:self.highlightedDate withState:self.currentState];
            }];
        }
    //}
}

- (ABViewPool*)buttonsPool
{
    if (_buttonsPool == nil)
        _buttonsPool = [[ABViewPool alloc] init];
    return _buttonsPool;
}

- (NSMutableArray*)dotLabels
{
    if (_dotLabels == nil)
        _dotLabels = [NSMutableArray array];
    return _dotLabels;
}

- (NSArray*)providers
{
    id null = (id)[NSNull null];
    return [NSArray arrayWithObjects:
            (self.weekdaysProvider != nil) ? self.weekdaysProvider : null,
            (self.daysProvider != nil) ? self.daysProvider : null,
            (self.monthsProvider != nil) ? self.monthsProvider : null,
            (self.yearsProvider != nil) ? self.yearsProvider : null,
            (self.erasProvider != nil) ? self.erasProvider : null,
            nil];
}

- (id<ABCalendarPickerDateProviderProtocol>)providerForState:(ABCalendarPickerState)state
{
    switch (state)
    {
        case ABCalendarPickerStateWeekdays:
            return self.weekdaysProvider;
        case ABCalendarPickerStateDays:
            return self.daysProvider;
        case ABCalendarPickerStateMonths:
            return self.monthsProvider;
        case ABCalendarPickerStateYears:
            return self.yearsProvider;
        case ABCalendarPickerStateEras:
            return self.erasProvider;
        default:
            return nil;
    }
}

- (id<ABCalendarPickerDateProviderProtocol>)currentProvider
{
    return [self providerForState:self.currentState];
}

- (void)setCalendar:(NSCalendar *)cal
{
    _calendar = cal;
    _calendar.minimumDaysInFirstWeek = 1;
    
    for (id<ABCalendarPickerDateProviderProtocol> provider in self.providers)
        if (provider != (id)[NSNull null])
            [provider setCalendar:cal];
    if (self.currentState == ABCalendarPickerStateDays
        || self.currentState == ABCalendarPickerStateWeekdays)
    {
        [self updateStateAnimated:YES];
    }
}

- (void)setWeekdaysProvider:(id<ABCalendarPickerDateProviderProtocol>)provider
{
    _weekdaysProvider = provider;
    [provider setDateOwner:self];
    [provider setCalendar:self.calendar];
    if (self.currentState == ABCalendarPickerStateWeekdays)
        if (self.superview)
            [self updateStateAnimated:YES];
}

- (void)setDaysProvider:(id<ABCalendarPickerDateProviderProtocol>)provider
{
    _daysProvider = provider;
    [provider setDateOwner:self];
    [provider setCalendar:self.calendar];
    if (self.currentState == ABCalendarPickerStateDays)
        if (self.superview)
            [self updateStateAnimated:YES];
}

- (void)setMonthsProvider:(id<ABCalendarPickerDateProviderProtocol>)provider
{
    _monthsProvider = provider;
    [provider setDateOwner:self];
    [provider setCalendar:self.calendar];
    if (self.currentState == ABCalendarPickerStateMonths)
        if (self.superview)
            [self updateStateAnimated:YES];
}

- (void)setYearsProvider:(id<ABCalendarPickerDateProviderProtocol>)provider
{
    _yearsProvider = provider;
    [provider setDateOwner:self];
    [provider setCalendar:self.calendar];
    if (self.currentState == ABCalendarPickerStateYears)
        if (self.superview)
            [self updateStateAnimated:YES];
}

- (void)setErasProvider:(id<ABCalendarPickerDateProviderProtocol>)provider
{
    _erasProvider = provider;
    [provider setDateOwner:self];
    [provider setCalendar:self.calendar];
    if (self.currentState == ABCalendarPickerStateEras)
        if (self.superview)
            [self updateStateAnimated:YES];
}

- (void)setStyleProvider:(id<ABCalendarPickerStyleProviderProtocol>)styleProvider
{
    _styleProvider = styleProvider;
    if (self.superview)
        [self updateStateAnimated:YES];
}

- (void)configureArrowButton:(UIButton *)button
                    withText:(NSString *)text
                     fastTap:(SEL)fastTapSel
                     deepTap:(SEL)deepTapSel
{
    button.titleLabel.font = [UIFont fontWithName:@"Hiragino Mincho ProN" size:20];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeMake(0,1);
    [button setTitle:text forState:UIControlStateNormal];
    
    UITapGestureRecognizer * tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:fastTapSel];
    UILongPressGestureRecognizer * deepPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:deepTapSel];
    deepPress.allowableMovement = 15.0;
    deepPress.cancelsTouchesInView = NO;
    
    [button addGestureRecognizer:tapPress];
    [button addGestureRecognizer:deepPress];
}

- (UIButton *)leftArrow
{
    if (_leftArrow == nil)
    {
        _leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configureArrowButton:_leftArrow
                          withText:UP_ARROW_STRING
                           fastTap:@selector(leftButtonClicked:)
                           deepTap:@selector(leftDeepPress:)];
        [self addSubview:_leftArrow];
    }
    return _leftArrow;
}

- (UIButton *)longLeftArrow
{
    if (_longLeftArrow == nil)
    {
        _longLeftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configureArrowButton:_longLeftArrow
                          withText:LEFT_ARROW_STRING
                           fastTap:@selector(longLeftButtonClicked:)
                           deepTap:@selector(longLeftDeepPress:)];
        [self addSubview:_longLeftArrow];
    }
    return _longLeftArrow;
}

- (UIButton *)rightArrow
{
    if (_rightArrow == nil)
    {
        _rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configureArrowButton:_rightArrow
                          withText:DOWN_ARROW_STRING
                           fastTap:@selector(rightButtonClicked:)
                           deepTap:@selector(rightDeepPress:)];
        [self addSubview:_rightArrow];
    }
    return _rightArrow;
}

- (UIButton *)longRightArrow
{
    if (_longRightArrow == nil)
    {
        _longRightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configureArrowButton:_longRightArrow
                          withText:RIGHT_ARROW_STRING
                           fastTap:@selector(longRightButtonClicked:)
                           deepTap:@selector(longRightDeepPress:)];
        [self addSubview:_longRightArrow];
    }
    return _longRightArrow;
}

#pragma mark -
#pragma mark Touch Interactions

- (void)titleClicked:(id)sender
{
    NSInteger index = [self.providers indexOfObject:self.currentProvider];
    if (index < self.providers.count-1 && [self.providers objectAtIndex:index+1] != nil)
        [self setState:self.currentState+1 animated:YES];
}

- (void)leftButtonClicked:(id)sender
{
    if (self.deepPressingInProgress)
    {
        self.deepPressingInProgress = NO;
        [self updateStateAnimated:NO];
        return;
    }
    
    BOOL canDiffuse = [self.currentProvider canDiffuse];
    UIControl * control = self.controls[0][0];
    if (canDiffuse < 2)
        canDiffuse = canDiffuse && !control.enabled;
    ABCalendarPickerAnimation animation = [self.currentProvider animationForPrev];
    self.highlightedDate = [self.currentProvider dateForPrevAnimation];
    [self changeStateTo:self.currentState fromState:self.currentState animation:animation canDiffuse:canDiffuse];
}

- (void)rightButtonClicked:(id)sender
{
    if (self.deepPressingInProgress)
    {
        self.deepPressingInProgress = NO;
        [self updateStateAnimated:NO];
        return;
    }
    
    NSInteger canDiffuse = [self.currentProvider canDiffuse];
    UIControl * control = [[self.controls lastObject] lastObject];
    if (canDiffuse < 2)
        canDiffuse = canDiffuse && !control.enabled;
    ABCalendarPickerAnimation animation = [self.currentProvider animationForNext];
    self.highlightedDate = [self.currentProvider dateForNextAnimation];
    [self changeStateTo:self.currentState fromState:self.currentState animation:animation canDiffuse:canDiffuse];
}

- (void)longLeftButtonClicked:(id)sender
{
    if (self.deepPressingInProgress)
    {
        self.deepPressingInProgress = NO;
        [self updateStateAnimated:NO];
        return;
    }
    
    if (![(id)self.currentProvider respondsToSelector:@selector(dateForLongPrevAnimation)])
        return;
    ABCalendarPickerAnimation animation = [self.currentProvider animationForLongPrev];
    self.highlightedDate = [self.currentProvider dateForLongPrevAnimation];
    [self changeStateTo:self.currentState fromState:self.currentState animation:animation canDiffuse:0];
}

- (void)longRightButtonClicked:(id)sender
{
    if (self.deepPressingInProgress)
    {
        self.deepPressingInProgress = NO;
        [self updateStateAnimated:NO];
        return;
    }
    
    if (![(id)self.currentProvider respondsToSelector:@selector(dateForLongNextAnimation)])
        return;
    ABCalendarPickerAnimation animation = [self.currentProvider animationForLongNext];
    self.highlightedDate = [self.currentProvider dateForLongNextAnimation];
    [self changeStateTo:self.currentState fromState:self.currentState animation:animation canDiffuse:0];
}

- (void)leftDeepPress:(UILongPressGestureRecognizer*)sender
{
    if (sender.state != UIGestureRecognizerStateBegan)
        return;
    self.deepPressingInProgress = YES;
    self.highlightedDate = [self.currentProvider dateForPrevAnimation];
    [self changeStateTo:self.currentState fromState:self.currentState animation:ABCalendarPickerAnimationNone canDiffuse:1];
    if (sender.state == UIGestureRecognizerStateBegan)
        [self performSelector:@selector(leftDeepPress:) withObject:sender afterDelay:0.1];
}

- (void)rightDeepPress:(UILongPressGestureRecognizer*)sender
{
    if (sender.state != UIGestureRecognizerStateBegan)
        return;
    self.deepPressingInProgress = YES;
    self.highlightedDate = [self.currentProvider dateForNextAnimation];
    [self changeStateTo:self.currentState fromState:self.currentState animation:ABCalendarPickerAnimationNone canDiffuse:1];
    if (sender.state == UIGestureRecognizerStateBegan)
        [self performSelector:@selector(rightDeepPress:) withObject:sender afterDelay:0.1];
}

- (void)longLeftDeepPress:(UILongPressGestureRecognizer*)sender
{
    if (sender.state != UIGestureRecognizerStateBegan)
        return;
    self.deepPressingInProgress = YES;
    self.highlightedDate = [self.currentProvider dateForLongPrevAnimation];
    [self changeStateTo:self.currentState fromState:self.currentState animation:ABCalendarPickerAnimationNone canDiffuse:0];
    if (sender.state == UIGestureRecognizerStateBegan)
        [self performSelector:@selector(longLeftDeepPress:) withObject:sender afterDelay:0.1];
}

- (void)longRightDeepPress:(UILongPressGestureRecognizer*)sender
{
    if (sender.state != UIGestureRecognizerStateBegan)
        return;
    self.deepPressingInProgress = YES;
    self.highlightedDate = [self.currentProvider dateForLongNextAnimation];
    [self changeStateTo:self.currentState fromState:self.currentState animation:ABCalendarPickerAnimationNone canDiffuse:0];
    if (sender.state == UIGestureRecognizerStateBegan)
        [self performSelector:@selector(longRightDeepPress:) withObject:sender afterDelay:0.1];
}

- (void)setHighlightedDelayed:(UIControl*)control
{
    control.highlighted = YES;
}

- (void)tapDetected:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [self convertPoint:[recognizer locationInView:recognizer.view] toView:self.mainTileView];
    
    for (int i = 0 ; i < [self.controls count]; i++)
    {
        NSArray * arr = [self.controls objectAtIndex:i];
        for (int j = 0; j < arr.count; j++)
        {
            UIControl * control = [arr objectAtIndex:j];
            
            if (CGRectContainsPoint(control.frame, point))
            {
                NSDate * date = [self.currentProvider dateForRow:i andColumn:j];
                
                BOOL needScrollPrev = NO;
                BOOL needScrollNext = NO;
                
                if ([(id)[self currentProvider] respondsToSelector:@selector(mainDateBegin)]
                    && [(id)[self currentProvider] respondsToSelector:@selector(mainDateEnd)])
                {
                    NSDate * mainDateBegin = [[self currentProvider] mainDateBegin];
                    NSDate * mainDateEnd = [[self currentProvider] mainDateEnd];
                    needScrollPrev = ([date compare:mainDateBegin] < 0);
                    needScrollNext = ([date compare:mainDateEnd] > 0);
                }
                
                if (!control.enabled && !needScrollPrev && !needScrollNext)
                {
                    needScrollPrev = YES;
                    needScrollNext = YES;
                }
                
                if (!needScrollPrev && !needScrollNext)
                {
                    if (!control.highlighted)
                    {
                        // Lets highlight
                        self.highlightedDate = date;
                        self.highlightedControl.highlighted = NO;
                        self.highlightedControl = control;
                        self.highlightedControl.highlighted = YES;
                        
                        [self.oldTileView bringSubviewToFront:self.selectedControl];
                        [self.oldTileView bringSubviewToFront:control];
                    }
                    else
                    {
                        // Lets segue in
                        NSInteger index = [self.providers indexOfObject:self.currentProvider];
                        if (index > 0 && [self.providers objectAtIndex:index-1] != nil)
                            [self setState:self.currentState-1 animated:YES];
                        else if (self.currentState == ABCalendarPickerStateWeekdays)
                            [self setState:self.currentState+1 animated:YES];
                        self.controlTouchBegin = nil;
                    }
                }
                else
                {
                    // Lets segue prev or next
                    self.highlightedDate = date;
                    
                    ABCalendarPickerAnimation animation;
                    if (needScrollPrev && needScrollNext)
                        animation = ABCalendarPickerAnimationTransition;
                    else if (needScrollPrev)
                        animation = [self.currentProvider animationForPrev];
                    else if (needScrollNext)
                        animation = [self.currentProvider animationForNext];
                    else
                        animation = ABCalendarPickerAnimationTransition;
                    
                    [self changeStateTo:self.currentState
                              fromState:self.currentState
                              animation:animation
                             canDiffuse:[self.currentProvider canDiffuse]];
                    return;
                }
            }
        }
    }
}

/*
- (void)tilesTouchedAt:(CGPoint)point moved:(BOOL)moved
{
    for (int i = 0 ; i < [self.controls count]; i++)
    {
        NSArray * arr = [self.controls objectAtIndex:i];
        for (int j = 0; j < arr.count; j++) 
        {
            UIControl * control = [arr objectAtIndex:j];
            
            if (CGRectContainsPoint(control.frame, point))
            {
                NSDate * date = [self.currentProvider dateForRow:i andColumn:j];
                
                if (control.enabled)
                {
                    if (control.highlighted)
                    {
                        if (!moved)
                            self.controlTouchBegin = control;
                    }
                    else 
                    {
                        // Lets highlight
                        self.highlightedDate = date;
                        self.highlightedControl.highlighted = NO;
                        self.highlightedControl = control;
                        self.highlightedControl.highlighted = YES;
                        
                        [self.oldTileView bringSubviewToFront:self.selectedControl];
                        [self.oldTileView bringSubviewToFront:control];
                    }
                }
                else
                {
                    // Lets segue prev or next
                    ABCalendarPickerAnimation animation = (i == 0) ? [self.currentProvider animationForPrev] : [self.currentProvider animationForNext];

                    self.highlightedDate = date;
                    if ([self.currentProvider rowsCount] == 1)
                        [self changeStateTo:self.currentState fromState:self.currentState animation:ABCalendarPickerAnimationTransition canDiffuse:1];
                    else
                        [self changeStateTo:self.currentState fromState:self.currentState animation:animation canDiffuse:[self.currentProvider canDiffuse]];
                    return;
                }
            }
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.oldTileView];
    [self tilesTouchedAt:point moved:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.oldTileView];
    [self tilesTouchedAt:point moved:YES];    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.oldTileView];
    
    for (NSArray * arr in self.controls)
    for (UIControl * control in arr)
        if (CGRectContainsPoint(control.frame, point))
        {
            if (control == self.controlTouchBegin)
            {
                // Lets segue in
                NSInteger index = [self.providers indexOfObject:self.currentProvider];
                if (index > 0 && [self.providers objectAtIndex:index-1] != nil)
                    [self setState:self.currentState-1 animated:YES];
                else if (self.currentState == ABCalendarPickerStateWeekdays)
                    [self setState:self.currentState+1 animated:YES];
                self.controlTouchBegin = nil;
            }
            return;
        }
    
    return;
}
*/

#pragma mark -
#pragma mark Animation Functions

- (void)updateColumnNamesForProvider:(id<ABCalendarPickerDateProviderProtocol>)provider
{
    NSInteger columnsCount = [provider columnsCount];
    CGFloat buttonWidth = self.bounds.size.width / columnsCount;
    
    if (self.columnLabels != nil)
        for (UILabel * label in self.columnLabels)
            [label removeFromSuperview];
    
    self.columnLabels = [NSMutableArray array];
    for (int j = 0; j < columnsCount; j++)
    {
        NSString * columnName = [provider columnName:j];
        if (columnName == nil)
            continue;
        
        UILabel * columnLabel = [[UILabel alloc] initWithFrame:CGRectMake(floor(j*buttonWidth),50-12,buttonWidth,12)];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
        columnLabel.textAlignment = NSTextAlignmentCenter;
#else
        columnLabel.textAlignment = UITextAlignmentCenter;
#endif
        columnLabel.backgroundColor = [UIColor clearColor];
		//columnLabel.shadowColor = [UIColor whiteColor];
		columnLabel.shadowOffset = CGSizeMake(0, 1);
        columnLabel.font = self.styleProvider.columnFont;
		columnLabel.font = [UIFont boldSystemFontOfSize:10.0f];
        columnLabel.text = columnName;
        //columnLabel.textColor = [UIColor darkGrayColor];
		
        columnLabel.textColor = self.styleProvider.textColor;
        columnLabel.shadowColor = self.styleProvider.textShadowColor;
        
        [self addSubview:columnLabel];
        [self.columnLabels addObject:columnLabel];
    }
}

- (void)updateTitleForProvider:(id<ABCalendarPickerDateProviderProtocol>)provider
{
    if (self.titleLabel == nil)
    {
        self.titleLabel = [[UILabel alloc] init];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
#else
        self.titleLabel.textAlignment = UITextAlignmentCenter;
#endif
        self.titleLabel.backgroundColor = [UIColor clearColor];
        //self.titleLabel.shadowColor = [UIColor whiteColor];
        self.titleLabel.shadowOffset = CGSizeMake(0, 1);
        self.titleLabel.font = (self.columnLabels.count == 0)
                             ? [self.styleProvider titleFontForColumnTitlesInvisible]
                             : [self.styleProvider titleFontForColumnTitlesVisible];
        //self.titleLabel.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
        //self.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    self.titleLabel.textColor = self.styleProvider.textColor;
    self.titleLabel.shadowColor = self.styleProvider.textShadowColor;
    
    if (self.titleButton == nil)
    {
        self.titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //[self.titleButton addTarget:self action:@selector(titleClicked:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClicked:)];
        [self.titleButton addGestureRecognizer:recognizer];
    }
    
    if (self.titleLabel.superview == nil)
        [self addSubview:self.titleLabel];
    if (self.titleButton.superview == nil)
        [self addSubview:self.titleButton];
    
    CGFloat buttonWidth = 160;
    CGFloat titleWidth = (self.longLeftArrow.hidden) ? 250 : 180;
    self.titleLabel.frame = CGRectMake(self.mainTileView.center.x - titleWidth/2,
                                       (self.columnLabels.count == 0) ? 7 : 2,
                                       titleWidth, 50-15);
    self.titleButton.frame = CGRectMake(self.titleLabel.center.x - buttonWidth/2, 0, buttonWidth, 45);
    
    self.titleLabel.text = [provider titleText];
    
    self.gradientBar.image = [self.styleProvider patternImageForGradientBar];
}

- (void)updateArrowsForProvider:(id<ABCalendarPickerDateProviderProtocol>)provider
{
    self.longLeftArrow.hidden = ![(id)provider respondsToSelector:@selector(dateForLongPrevAnimation)];
    self.longRightArrow.hidden = ![(id)provider respondsToSelector:@selector(dateForLongNextAnimation)];
    
    if ([provider animationForPrev] == ABCalendarPickerAnimationScrollUp)
        [self.leftArrow setTitle:UP_ARROW_STRING forState:UIControlStateNormal];
    else if ([provider animationForPrev] == ABCalendarPickerAnimationScrollLeft)
        [self.leftArrow setTitle:LEFT_ARROW_STRING forState:UIControlStateNormal];
    
    if ([provider animationForNext] == ABCalendarPickerAnimationScrollDown)
        [self.rightArrow setTitle:DOWN_ARROW_STRING forState:UIControlStateNormal];
    else if ([provider animationForNext] == ABCalendarPickerAnimationScrollRight)
        [self.rightArrow setTitle:RIGHT_ARROW_STRING forState:UIControlStateNormal];
    
    if ([(id)provider respondsToSelector:@selector(animationForLongPrev)])
    {
        if ([provider animationForLongPrev] == ABCalendarPickerAnimationScrollUp)
            [self.longLeftArrow setTitle:UP_ARROW_STRING forState:UIControlStateNormal];
        else if ([provider animationForLongPrev] == ABCalendarPickerAnimationScrollLeft)
            [self.longLeftArrow setTitle:LEFT_ARROW_STRING forState:UIControlStateNormal];
    
        if ([provider animationForLongNext] == ABCalendarPickerAnimationScrollDown)
            [self.longRightArrow setTitle:DOWN_ARROW_STRING forState:UIControlStateNormal];
        else if ([provider animationForLongNext] == ABCalendarPickerAnimationScrollRight)
            [self.longRightArrow setTitle:RIGHT_ARROW_STRING forState:UIControlStateNormal];
    }
    
    self.leftArrow.frame = CGRectMake((self.longLeftArrow.hidden ? 0 : 35), 3, 40, 45);
    [self.leftArrow setTitleColor:self.styleProvider.textColor forState:UIControlStateNormal];
    [self.leftArrow setTitleShadowColor:self.styleProvider.textShadowColor forState:UIControlStateNormal];
    
    self.rightArrow.frame = CGRectMake(self.bounds.size.width-40-(self.longRightArrow.hidden ? 0 : 35), 3, 40, 45);
    [self.rightArrow setTitleColor:self.styleProvider.textColor forState:UIControlStateNormal];
    [self.rightArrow setTitleShadowColor:self.styleProvider.textShadowColor forState:UIControlStateNormal];
    
    if (!self.longLeftArrow.hidden)
    {
        self.longLeftArrow.frame = CGRectMake(0, 3, 35, 45);
        [self.longLeftArrow setTitleColor:self.styleProvider.textColor forState:UIControlStateNormal];
        [self.longLeftArrow setTitleShadowColor:self.styleProvider.textShadowColor forState:UIControlStateNormal];
        
    }
    if (!self.longRightArrow.hidden)
    {
        self.longRightArrow.frame = CGRectMake(self.bounds.size.width-35, 3, 35, 45);
        [self.longRightArrow setTitleColor:self.styleProvider.textColor forState:UIControlStateNormal];
        [self.longRightArrow setTitleShadowColor:self.styleProvider.textShadowColor forState:UIControlStateNormal];
    }
}

- (void)updateDotsForProvider:(id<ABCalendarPickerDateProviderProtocol>)provider
{
    if ([[self.leftArrow.gestureRecognizers lastObject] state] == UIGestureRecognizerStateBegan
        || [[self.rightArrow.gestureRecognizers lastObject] state] == UIGestureRecognizerStateBegan
        || [[self.longLeftArrow.gestureRecognizers lastObject] state] == UIGestureRecognizerStateBegan
        || [[self.longRightArrow.gestureRecognizers lastObject] state] == UIGestureRecognizerStateBegan)
    {
        return;
    }
    
    for (int i = 0; i < self.controls.count; i++)
    {
        NSArray * arr = [self.controls objectAtIndex:i];
        for (int j = 0; j < arr.count; j++)
        {
            UIControl * control = [arr objectAtIndex:j];
            
            NSDate * buttonDate = [provider dateForRow:i andColumn:j];
            UIControlState controlState = [provider controlStateForDate:buttonDate];
            NSInteger eventsCount = [self.dataSource calendarPicker:self numberOfEventsForDate:buttonDate onState:self.currentState];
            
            [self.styleProvider calendarPicker:self postUpdateForCellView:control onControlState:controlState withEvents:eventsCount andState:self.currentState];
        }
    }
    
    [self.nowTileView setNeedsDisplay];
}

- (void)updateButtonsForProvider:(id<ABCalendarPickerDateProviderProtocol>)provider andState:(ABCalendarPickerState)state
{
    // Performance optimization
    NSInteger rowsCount = [provider rowsCount];
    NSInteger columnsCount = [provider columnsCount];
    CGFloat buttonWidth = floor((self.bounds.size.width + 2) / columnsCount);
    CGFloat buttonHeight = buttonWidth;
    
    self.selectedControl = nil;
    self.highlightedControl = nil;
    
    self.dotLabelsToRemove = self.dotLabels.count;
    
    self.controls = [NSMutableArray array];
    for (int i = 0; i < rowsCount; i++)
    {
        [self.controls addObject:[NSMutableArray array]];
        for (int j = 0; j < columnsCount; j++)
        {
            NSDate * buttonDate = [provider dateForRow:i andColumn:j];
            NSString * label = [provider labelForDate:buttonDate];
            UIControlState controlState = [provider controlStateForDate:buttonDate];
            
            UIControl * control = [self.styleProvider calendarPicker:self cellViewForTitle:label andState:self.currentState];
            
            CGFloat shift = (j < columnsCount - 1) ? 0 : (self.bounds.size.width + 1 - columnsCount*buttonWidth);
            control.frame = CGRectMake(j*buttonWidth-1, i*buttonHeight, buttonWidth+1+shift, buttonHeight+1);

            control.enabled = ((controlState & UIControlStateDisabled) == 0);
            control.selected = ((controlState & UIControlStateSelected) != 0);
            control.highlighted = ((controlState & UIControlStateHighlighted) != 0);
            
            if ((controlState & UIControlStateSelected) != 0)
                self.selectedControl = control;
            if ((controlState & UIControlStateHighlighted) != 0)
                self.highlightedControl = control;

            [self.nowTileView addSubview:control];
            [[self.controls lastObject] addObject:control];
        }
    }
    
    if (state == ABCalendarPickerStateDays
        && [(id)self.dataSource respondsToSelector:@selector(calendarPicker:numberOfEventsForDate:onState:)])
    {
        [self performSelector:@selector(updateDotsForProvider:) withObject:provider afterDelay:0.0];
    }
    
    if (state == ABCalendarPickerStateWeekdays
        && [(id)self.dataSource respondsToSelector:@selector(calendarPicker:numberOfEventsForDate:onState:)])
    {
        [self updateDotsForProvider:provider];
        //[self performSelector:@selector(updateDotsForProvider:) withObject:provider afterDelay:0.0];
    }
    
    [self.nowTileView bringSubviewToFront:self.selectedControl];
    [self.nowTileView bringSubviewToFront:self.highlightedControl];
}

#pragma mark -
#pragma mark Different Animations

- (void)preAnimateZoomOutFromView:(UIView*)fromView
                           toView:(UIView*)toView
                     inParentView:(UIView*)parentView
{
    toView.alpha = 0;
    [parentView insertSubview:toView atIndex:0];
}

- (void)animateZoomOutFromView:(UIView*)fromView
                        toView:(UIView*)toView
                  inParentView:(UIView*)parentView
{
    fromView.center = CGPointMake(self.highlightedControl.center.x, self.highlightedControl.center.y);
    fromView.transform = CGAffineTransformMakeScale(self.highlightedControl.bounds.size.width / fromView.frame.size.width,
                                                    self.highlightedControl.bounds.size.height / fromView.frame.size.height);
}

- (void)preAnimateZoomInFromView:(UIView*)fromView
                          toView:(UIView*)toView
                    inParentView:(UIView*)parentView
                 oldButtonCenter:(CGPoint)oldButtonCenter
                   oldButtonSize:(CGSize)oldButtonSize
{
    toView.alpha = 0;
    [parentView addSubview:toView];
    toView.center = CGPointMake(oldButtonCenter.x, oldButtonCenter.y);
    toView.transform = CGAffineTransformMakeScale(oldButtonSize.width / toView.frame.size.width,
                                                  oldButtonSize.height / toView.frame.size.height);
}

- (void)animateZoomInFromView:(UIView*)fromView
                       toView:(UIView*)toView
                 inParentView:(UIView*)parentView
{
    toView.transform = CGAffineTransformIdentity;
    toView.frame = parentView.bounds;
}

- (void)preAnimateScrollUpFromView:(UIView*)fromView
                            toView:(UIView*)toView
                      inParentView:(UIView*)parentView
                        canDiffuse:(NSInteger)canDiffuse
                 lastButtonEnabled:(BOOL)lastButtonEnabled
                      buttonHeight:(CGFloat)buttonHeight
{
    toView.alpha = 0;
    [parentView addSubview:toView];
    toView.center = CGPointMake(fromView.center.x,
                                toView.center.y + 1
                                - toView.frame.size.height
                                + buttonHeight*canDiffuse);
}

- (void)animateScrollUpFromView:(UIView*)fromView
                         toView:(UIView*)toView
                   inParentView:(UIView*)parentView
                     canDiffuse:(NSInteger)canDiffuse
              lastButtonEnabled:(BOOL)lastButtonEnabled
                   buttonHeight:(CGFloat)buttonHeight
{
    toView.center = CGPointMake(parentView.bounds.size.width/2,(parentView.bounds.size.height)/2);
    fromView.center = CGPointMake(fromView.center.x,
                                  fromView.center.y - 1
                                  + toView.frame.size.height
                                  - buttonHeight*canDiffuse);
}

- (void)preAnimateScrollDownFromView:(UIView*)fromView
                              toView:(UIView*)toView
                        inParentView:(UIView*)parentView
                          canDiffuse:(NSInteger)canDiffuse
                  firstButtonEnabled:(BOOL)firstButtonEnabled
                        buttonHeight:(CGFloat)buttonHeight
{
    toView.alpha = 0;
    [parentView addSubview:toView];
    toView.center = CGPointMake(fromView.center.x,
                                toView.center.y - 1
                                + fromView.frame.size.height
                                - buttonHeight*canDiffuse);
}

- (void)animateScrollDownFromView:(UIView*)fromView
                           toView:(UIView*)toView
                     inParentView:(UIView*)parentView
                       canDiffuse:(NSInteger)canDiffuse
               firstButtonEnabled:(BOOL)firstButtonEnabled
                     buttonHeight:(CGFloat)buttonHeight
{
    toView.center = CGPointMake(parentView.bounds.size.width/2,(parentView.bounds.size.height)/2);
    fromView.center = CGPointMake(fromView.center.x,
                                  fromView.center.y + 1
                                  - fromView.frame.size.height
                                  + buttonHeight*canDiffuse);
}

- (void)preAnimateScrollLeftFromView:(UIView*)fromView
                              toView:(UIView*)toView
                        inParentView:(UIView*)parentView
                          canDiffuse:(NSInteger)canDiffuse
                   lastButtonEnabled:(BOOL)lastButtonEnabled
                         buttonWidth:(CGFloat)buttonWidth
{
    toView.alpha = 0;
    [parentView addSubview:toView];
    toView.center = CGPointMake(fromView.center.x - 1
                                - toView.frame.size.width
                                + buttonWidth*canDiffuse,
                                toView.center.y);
}

- (void)animateScrollLeftFromView:(UIView*)fromView
                           toView:(UIView*)toView
                     inParentView:(UIView*)parentView
                       canDiffuse:(NSInteger)canDiffuse
                lastButtonEnabled:(BOOL)lastButtonEnabled
                      buttonWidth:(CGFloat)buttonWidth
{
    toView.center = CGPointMake(parentView.bounds.size.width/2,(parentView.bounds.size.height)/2);
    fromView.center = CGPointMake(fromView.center.x + 1
                                  + toView.frame.size.width
                                  - buttonWidth*canDiffuse,
                                  fromView.center.y);
}

- (void)preAnimateScrollRightFromView:(UIView*)fromView
                               toView:(UIView*)toView
                         inParentView:(UIView*)parentView
                           canDiffuse:(NSInteger)canDiffuse
                   firstButtonEnabled:(BOOL)firstButtonEnabled
                          buttonWidth:(CGFloat)buttonWidth
{
    toView.alpha = 0;
    [parentView addSubview:toView];
    toView.center = CGPointMake(fromView.center.x + 1
                                + fromView.frame.size.width
                                - buttonWidth*canDiffuse,
                                toView.center.y);
}

- (void)animateScrollRightFromView:(UIView*)fromView
                            toView:(UIView*)toView
                      inParentView:(UIView*)parentView
                        canDiffuse:(NSInteger)canDiffuse
                firstButtonEnabled:(BOOL)firstButtonEnabled
                       buttonWidth:(CGFloat)buttonWidth
{
    toView.center = CGPointMake(parentView.bounds.size.width/2,(parentView.bounds.size.height)/2);
    fromView.center = CGPointMake(fromView.center.x - 1
                                  - fromView.frame.size.width
                                  + buttonWidth*canDiffuse,
                                  fromView.center.y);
}

#pragma mark -

- (BOOL)animationEq:(ABCalendarPickerAnimation)animation toDirection:(UISwipeGestureRecognizerDirection)direction
{
    return (animation == ABCalendarPickerAnimationScrollUp
            && direction == UISwipeGestureRecognizerDirectionDown)
        || (animation == ABCalendarPickerAnimationScrollDown
            && direction == UISwipeGestureRecognizerDirectionUp)
        || (animation == ABCalendarPickerAnimationScrollLeft
            && direction == UISwipeGestureRecognizerDirectionRight)
        || (animation == ABCalendarPickerAnimationScrollRight
            && direction == UISwipeGestureRecognizerDirectionLeft);
}

- (void)anySwiped:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if (!self.swipeNavigationEnabled)
        return;
    
    BOOL canDiffuse = [self.currentProvider canDiffuse];
    
    ABCalendarPickerAnimation prevAnimation = [self.currentProvider animationForPrev];
    ABCalendarPickerAnimation nextAnimation = [self.currentProvider animationForNext];
    if ([self animationEq:prevAnimation toDirection:gestureRecognizer.direction])
    {
        UIControl * control = self.controls[0][0];
        if (canDiffuse < 2)
            canDiffuse = canDiffuse && !control.enabled;
        self.highlightedDate = [self.currentProvider dateForPrevAnimation];
        [self changeStateTo:self.currentState fromState:self.currentState animation:prevAnimation canDiffuse:canDiffuse];
    }
    if ([self animationEq:nextAnimation toDirection:gestureRecognizer.direction])
    {
        UIControl * control = [[self.controls lastObject] lastObject];
        if (canDiffuse < 2)
            canDiffuse = canDiffuse && !control.enabled;
        self.highlightedDate = [self.currentProvider dateForNextAnimation];
        [self changeStateTo:self.currentState fromState:self.currentState animation:nextAnimation canDiffuse:canDiffuse];
    }
    
    if (![(id)self.currentProvider respondsToSelector:@selector(dateForLongPrevAnimation)]
        || ![(id)self.currentProvider respondsToSelector:@selector(dateForLongNextAnimation)])
    {
        return;
    }
    
    ABCalendarPickerAnimation longPrevAnimation = [self.currentProvider animationForLongPrev];
    ABCalendarPickerAnimation longNextAnimation = [self.currentProvider animationForLongNext];
    if ([self animationEq:longPrevAnimation toDirection:gestureRecognizer.direction])
    {
        //UIControl * control = self.controls[0][0];
        //canDiffuse = canDiffuse && !control.enabled;
        canDiffuse = NO;
        self.highlightedDate = [self.currentProvider dateForLongPrevAnimation];
        [self changeStateTo:self.currentState fromState:self.currentState animation:longPrevAnimation canDiffuse:canDiffuse];
    }
    if ([self animationEq:longNextAnimation toDirection:gestureRecognizer.direction])
    {
        //UIControl * control = [[self.controls lastObject] lastObject];
        //canDiffuse = canDiffuse && !control.enabled;
        canDiffuse = NO;
        self.highlightedDate = [self.currentProvider dateForLongNextAnimation];
        [self changeStateTo:self.currentState fromState:self.currentState animation:longNextAnimation canDiffuse:canDiffuse];
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    for (int i = 0; i < self.dotLabelsToRemove; i++)
    {
        [[self.dotLabels objectAtIndex:0] removeFromSuperview];
        [self.dotLabels removeObjectAtIndex:0];
    }

    [self.oldTileView removeFromSuperview];
    self.oldTileView = self.nowTileView;
    self.nowTileView = nil;
    
    // Delegate talks
    if (self.currentState != self.previousState)
    {
        if ([(id)self.delegate respondsToSelector:@selector(calendarPicker:didSetState:fromState:)])
            [self.delegate calendarPicker:self didSetState:self.currentState fromState:self.previousState];
    }
    
    self.userInteractionEnabled = YES;
}

- (void)changeStateTo:(ABCalendarPickerState)toState
            fromState:(ABCalendarPickerState)fromState
            animation:(ABCalendarPickerAnimation)animation
           canDiffuse:(NSInteger)canDiffuse
{
    if (!self.userInteractionEnabled)
        return;
    self.userInteractionEnabled = NO;
    
    // Delegate talks
    if (toState != fromState)
    {
        if ([(id)self.delegate respondsToSelector:@selector(calendarPicker:shouldSetState:fromState:)]
            && ![self.delegate calendarPicker:self shouldSetState:toState fromState:fromState])
        {
            self.userInteractionEnabled = YES;
            return;
        }
        
        if ([(id)self.delegate respondsToSelector:@selector(calendarPicker:willSetState:fromState:)])
            [self.delegate calendarPicker:self willSetState:toState fromState:fromState];
    }
    
    id<ABCalendarPickerDateProviderProtocol> provider = [self providerForState:toState];
    if (provider == nil)
    {
        self.userInteractionEnabled = YES;
        return;
    }
    
    CGPoint oldHighlightedButtonCenter = self.highlightedControl.center;
    CGSize oldHighlightedButtonSize = self.highlightedControl.frame.size;
    
    NSInteger rowsCount = [provider rowsCount];
    NSInteger columnsCount = [provider columnsCount];
    CGFloat buttonWidth = floor((self.bounds.size.width + 2) / columnsCount);
    CGFloat buttonHeight = buttonWidth;
    
    CGFloat oldFrameBottom = self.frame.origin.y + self.frame.size.height;
    CGFloat newFrameHeight = 50.0 + buttonHeight*rowsCount + 1;

    if (self.gradientBar == nil)
    {
        self.gradientBar = [[UIImageView alloc] initWithImage:[self imageNamed:@"GradientBar"]];
        self.gradientBar.frame = CGRectMake(0, 0, self.bounds.size.width, 50);
        [self addSubview:self.gradientBar];
    }
    
    if (self.mainTileView == nil)
    {
        self.mainTileView = [[UIView alloc] initWithFrame:CGRectMake(0,50,self.frame.size.width,self.frame.size.height-50)];
        self.mainTileView.userInteractionEnabled = NO;
        self.mainTileView.clipsToBounds = YES;
        self.mainTileView.backgroundColor = [UIColor colorWithRed:164/255. green:167/255. blue:176/255. alpha:1.0];
        [self addSubview:self.mainTileView];
        
        UISwipeGestureRecognizer * topRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(anySwiped:)];
        topRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        topRecognizer.cancelsTouchesInView = YES;
        
        UISwipeGestureRecognizer * bottomRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(anySwiped:)];
        bottomRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        bottomRecognizer.cancelsTouchesInView = YES;
        
        UISwipeGestureRecognizer * leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(anySwiped:)];
        leftRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        leftRecognizer.cancelsTouchesInView = YES;
        
        UISwipeGestureRecognizer * rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(anySwiped:)];
        rightRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        rightRecognizer.cancelsTouchesInView = YES;
        
        [self addGestureRecognizer:topRecognizer];
        [self addGestureRecognizer:bottomRecognizer];
        [self addGestureRecognizer:leftRecognizer];
        [self addGestureRecognizer:rightRecognizer];
    }
    
    if (self.patternImage == nil)
        self.patternImage = [[self imageNamed:@"TilePattern"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 0, 0, 2)];
    
    CGRect newTileRect = CGRectMake(0, 0, self.mainTileView.bounds.size.width, buttonHeight*rowsCount + 1);
    self.nowTileView = [[UIView alloc] initWithFrame:newTileRect];
    self.nowTileView.contentMode = UIViewContentModeCenter;
    self.nowTileView.clearsContextBeforeDrawing = NO;
    self.nowTileView.autoresizesSubviews = NO;
    self.nowTileView.clipsToBounds = YES;
    self.nowTileView.opaque = NO;

    // Updating all elements
    
    [self updateButtonsForProvider:provider andState:toState];
    [self updateColumnNamesForProvider:provider];
    [self updateArrowsForProvider:provider];
    [self updateTitleForProvider:provider];
    
    // NO Animation
    
    if (animation == ABCalendarPickerAnimationNone)
    {
        CGFloat oldFrameHeight = self.frame.size.height;
        self.frame = CGRectMake(self.frame.origin.x,
                                self.bottomExpanding ? self.frame.origin.y : (oldFrameBottom - newFrameHeight), 
                                self.frame.size.width,
                                newFrameHeight);
        self.mainTileView.frame = CGRectMake(0,50,self.frame.size.width,self.frame.size.height-50);
        if (oldFrameHeight != newFrameHeight)
        {
            if ([(id)self.delegate respondsToSelector:@selector(calendarPicker:animateNewHeight:)])
                [self.delegate calendarPicker:self animateNewHeight:newFrameHeight];
        }
            
        [self.mainTileView addSubview:self.nowTileView];
        self.previousState = self.currentState;
        self.currentState = toState;

        [self animationDidStop:nil finished:nil context:nil];
        return;
    }
    
    // Animation
    
    UIButton * firstButton = [[self.controls objectAtIndex:0] objectAtIndex:0];
    UIButton * lastButton = [[self.controls lastObject] lastObject];
    
    UIView * fromView = self.oldTileView;
    UIView * toView = self.nowTileView;

    NSInteger shift = 0;
    CGFloat duration = 0.3;
    switch (animation)
    {
        case ABCalendarPickerAnimationZoomOut:
            [self preAnimateZoomOutFromView:fromView
                                     toView:toView
                               inParentView:self.mainTileView];
            break;
        case ABCalendarPickerAnimationZoomIn:
            [self preAnimateZoomInFromView:fromView
                                    toView:toView
                              inParentView:self.mainTileView
                           oldButtonCenter:oldHighlightedButtonCenter
                             oldButtonSize:oldHighlightedButtonSize];
            break;
            
        case ABCalendarPickerAnimationScrollUp:
            duration = 0.4;
            [self preAnimateScrollUpFromView:fromView
                                      toView:toView
                                inParentView:self.mainTileView
                                  canDiffuse:canDiffuse
                           lastButtonEnabled:lastButton.enabled
                                buttonHeight:buttonHeight];
            break;
        case ABCalendarPickerAnimationScrollDown:
            duration = 0.4;
            [self preAnimateScrollDownFromView:fromView
                                        toView:toView
                                  inParentView:self.mainTileView
                                    canDiffuse:canDiffuse
                            firstButtonEnabled:firstButton.enabled
                                  buttonHeight:buttonHeight];
            break;
        case ABCalendarPickerAnimationScrollLeft:
            duration = 0.4;
            [self preAnimateScrollLeftFromView:fromView
                                        toView:toView
                                  inParentView:self.mainTileView
                                    canDiffuse:canDiffuse
                             lastButtonEnabled:lastButton.enabled
                                   buttonWidth:buttonWidth];
            break;
        case ABCalendarPickerAnimationScrollRight:
            duration = 0.4;
            [self preAnimateScrollRightFromView:fromView
                                         toView:toView
                                   inParentView:self.mainTileView
                                     canDiffuse:canDiffuse
                             firstButtonEnabled:firstButton.enabled
                                    buttonWidth:buttonWidth];
            break;
            
        case ABCalendarPickerAnimationScrollUpFor1Rows:
        case ABCalendarPickerAnimationScrollUpFor2Rows:
        case ABCalendarPickerAnimationScrollUpFor3Rows:
        case ABCalendarPickerAnimationScrollUpFor4Rows:
        case ABCalendarPickerAnimationScrollUpFor5Rows:
        case ABCalendarPickerAnimationScrollUpFor6Rows:
            duration = 0.4;
            shift = animation - ABCalendarPickerAnimationScrollUpOrDownBase;
            shift -= ([provider rowsCount] - 1) / 2;
            [self.mainTileView insertSubview:toView atIndex:0];
            toView.center = CGPointMake(toView.center.x, toView.center.y + (shift-1)*buttonHeight);
            break;

        case ABCalendarPickerAnimationScrollDownFor1Rows:
        case ABCalendarPickerAnimationScrollDownFor2Rows:
        case ABCalendarPickerAnimationScrollDownFor3Rows:
        case ABCalendarPickerAnimationScrollDownFor4Rows:
        case ABCalendarPickerAnimationScrollDownFor5Rows:
        case ABCalendarPickerAnimationScrollDownFor6Rows:
            duration = 0.4;
            shift = ABCalendarPickerAnimationScrollUpOrDownBase - animation;
            shift -= ([[self currentProvider] rowsCount] - 1) / 2;
            [self.mainTileView insertSubview:toView atIndex:0];
            toView.center = CGPointMake(toView.center.x, toView.center.y - (shift-1)*buttonHeight);
            break;

        default:
            toView.alpha = 0;
            [self.mainTileView insertSubview:toView atIndex:0];
            break;
    }
     
    CGFloat delay = 0.0;
    if (animation == ABCalendarPickerAnimationScrollUp
        || animation == ABCalendarPickerAnimationScrollDown
        || animation == ABCalendarPickerAnimationScrollLeft
        || animation == ABCalendarPickerAnimationScrollRight)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.1];
        [self.mainTileView bringSubviewToFront:toView];
        toView.alpha = 1;
        [UIView commitAnimations];
        delay = 0.1;
    }
    
    if (canDiffuse == 0) // no diffusion - no transition
    {
        toView.alpha = 1;
        fromView.alpha = 1;
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelay:delay];
	[UIView setAnimationDuration:duration];
    
    if (canDiffuse > 0) // no diffusion - no transition
    {
        toView.alpha = 1;
        if (animation != ABCalendarPickerAnimationScrollUp
            && animation != ABCalendarPickerAnimationScrollDown
            && animation != ABCalendarPickerAnimationScrollLeft
            && animation != ABCalendarPickerAnimationScrollRight)
        {
            fromView.alpha = 0;
        }
    }

    CGFloat oldFrameHeight = self.frame.size.height;
    self.frame = CGRectMake(self.frame.origin.x,
                            self.bottomExpanding ? self.frame.origin.y : (oldFrameBottom - newFrameHeight),
                            self.frame.size.width,
                            newFrameHeight);
    self.mainTileView.frame = CGRectMake(0,50,self.frame.size.width,self.frame.size.height-50);
    if (oldFrameHeight != newFrameHeight)
    {
        if ([(id)self.delegate respondsToSelector:@selector(calendarPicker:animateNewHeight:)])
            [self.delegate calendarPicker:self animateNewHeight:newFrameHeight];
    }

    switch (animation)
    {
        case ABCalendarPickerAnimationZoomOut:
            [self animateZoomOutFromView:fromView
                                  toView:toView
                            inParentView:self.mainTileView];
            break;
        case ABCalendarPickerAnimationZoomIn:
            [self animateZoomInFromView:fromView
                                 toView:toView
                           inParentView:self.mainTileView];
            break;
        
        case ABCalendarPickerAnimationScrollUp:
            [self animateScrollUpFromView:fromView
                                   toView:toView
                             inParentView:self.mainTileView
                               canDiffuse:canDiffuse
                        lastButtonEnabled:lastButton.enabled
                             buttonHeight:buttonHeight];
            break;
        case ABCalendarPickerAnimationScrollDown:
            [self animateScrollDownFromView:fromView
                                     toView:toView
                               inParentView:self.mainTileView
                                 canDiffuse:canDiffuse
                         firstButtonEnabled:firstButton.enabled
                               buttonHeight:buttonHeight];
            break;
        case ABCalendarPickerAnimationScrollLeft:
            [self animateScrollLeftFromView:fromView
                                     toView:toView
                               inParentView:self.mainTileView
                                 canDiffuse:canDiffuse
                          lastButtonEnabled:lastButton.enabled
                                buttonWidth:buttonWidth];
            break;
        case ABCalendarPickerAnimationScrollRight:
            [self animateScrollRightFromView:fromView
                                      toView:toView
                                inParentView:self.mainTileView
                                  canDiffuse:canDiffuse
                          firstButtonEnabled:firstButton.enabled
                                 buttonWidth:buttonWidth];
            break;
            
        case ABCalendarPickerAnimationScrollUpFor1Rows:
        case ABCalendarPickerAnimationScrollUpFor2Rows:
        case ABCalendarPickerAnimationScrollUpFor3Rows:
        case ABCalendarPickerAnimationScrollUpFor4Rows:
        case ABCalendarPickerAnimationScrollUpFor5Rows:
        case ABCalendarPickerAnimationScrollUpFor6Rows:
            fromView.center = CGPointMake(fromView.center.x, fromView.center.y - buttonHeight*(shift-1));
            toView.center = CGPointMake(toView.bounds.size.width/2, toView.bounds.size.height/2);
            break;
            
        case ABCalendarPickerAnimationScrollDownFor1Rows:
        case ABCalendarPickerAnimationScrollDownFor2Rows:
        case ABCalendarPickerAnimationScrollDownFor3Rows:
        case ABCalendarPickerAnimationScrollDownFor4Rows:
        case ABCalendarPickerAnimationScrollDownFor5Rows:
        case ABCalendarPickerAnimationScrollDownFor6Rows:
            toView.frame = CGRectMake(0, 0, toView.bounds.size.width, toView.bounds.size.height);
            fromView.center = CGPointMake(fromView.center.x, fromView.center.y + buttonHeight*(shift-1));
            break;
            
        default:
            break;
    };

    [UIView commitAnimations];
    
    [self.nowTileView setNeedsDisplay];
    
    self.previousState = self.currentState;
    self.currentState = toState;
}

#pragma mark -
#pragma mark Initialization

- (void)initWithStyleProvider:(id<ABCalendarPickerStyleProviderProtocol>)styleProvider
             weekdaysProvider:(id<ABCalendarPickerDateProviderProtocol>)weekdaysProvider
                 daysProvider:(id<ABCalendarPickerDateProviderProtocol>)daysProvider
               monthsProvider:(id<ABCalendarPickerDateProviderProtocol>)monthsProvider
                yearsProvider:(id<ABCalendarPickerDateProviderProtocol>)yearsProvider
                 erasProvider:(id<ABCalendarPickerDateProviderProtocol>)erasProvider
{
    self.backgroundColor = [UIColor colorWithRed:220/255. green:220/255. blue:220/255. alpha:1.0];
    self.bottomExpanding = YES;
    self.swipeNavigationEnabled = YES;
    self.deepPressingInProgress = NO;
    
    self.selectedDate = [NSDate date];
    self.highlightedDate = self.selectedDate;
    
    self.styleProvider = styleProvider;
    self.weekdaysProvider = weekdaysProvider;
    self.daysProvider = daysProvider;
    self.monthsProvider = monthsProvider;
    self.yearsProvider = yearsProvider;
    self.erasProvider = erasProvider;

    self.calendar = [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
    //self.calendar = [NSCalendar currentCalendar];//[[NSCalendar alloc] initWithCalendarIdentifier:calendarId];
    //self.calendar.firstWeekday = 2;
    
    [self setState:ABCalendarPickerStateDays animated:NO];
    
    UITapGestureRecognizer * singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    UITapGestureRecognizer * doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClicked:)];
    doubleTapRecognizer.numberOfTouchesRequired = 2;
    [self addGestureRecognizer:singleTapRecognizer];
    [self addGestureRecognizer:doubleTapRecognizer];
}

- (void)initWithDefaultProviders
{
    [self initWithStyleProvider:[[ABCalendarPickerDefaultStyleProvider alloc] init]
               weekdaysProvider:[[ABCalendarPickerDefaultTripleWeekdaysProvider alloc] init]
                   daysProvider:[[ABCalendarPickerDefaultDaysProvider alloc] init]
                 monthsProvider:[[ABCalendarPickerDefaultSeasonedMonthsProvider alloc] init]
                  yearsProvider:[[ABCalendarPickerDefaultYearsProvider alloc] init]
                   erasProvider:nil];//[[ABCalendarPickerDefaultErasProvider alloc] init]];
}

- (id)init
{
    if (self = [super init])
        [self initWithDefaultProviders];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        [self initWithDefaultProviders];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
        [self initWithDefaultProviders];
    return self;
}

#pragma mark -
#pragma mark Public Methods

- (void)updateStateAnimated:(BOOL)animated
{
    [self setState:self.currentState animated:animated];
    if ([(id)self.delegate respondsToSelector:@selector(calendarPicker:dateSelected:withState:)])
        [self.delegate calendarPicker:self dateSelected:self.highlightedDate withState:self.currentState];
}

- (void)setDate:(NSDate*)date andState:(ABCalendarPickerState)state animated:(BOOL)animated
{
    self.highlightedDate = date;
    [self setState:state animated:animated];
}

- (void)setState:(ABCalendarPickerState)state animated:(BOOL)animated
{
    ABCalendarPickerAnimation animation = ABCalendarPickerAnimationNone;
    BOOL canDiffuse = NO;
    if (animated)
    {
        id<ABCalendarPickerDateProviderProtocol> fromProvider = self.currentProvider;
        id<ABCalendarPickerDateProviderProtocol> toProvider = [self providerForState:state];
        
        if (state == self.currentState)
        {
            animation = ABCalendarPickerAnimationTransition;
            canDiffuse = [toProvider canDiffuse];
        }
        
        if (state > self.currentState)
        {
            if ([(id)fromProvider respondsToSelector:@selector(animationForZoomOutToProvider:)])
                animation = [fromProvider animationForZoomOutToProvider:toProvider];
            //else if ([(id)toProvider respondsToSelector:@selector(animationForZoomOutFromProvider:)])
            //    animation = [toProvider animationForZoomOutFromProvider:fromProvider];
        }
        
        if (state < self.currentState)
        {
            if ([(id)fromProvider respondsToSelector:@selector(animationForZoomInToProvider:)])
                animation = [fromProvider animationForZoomInToProvider:toProvider];
            //else if ([(id)toProvider respondsToSelector:@selector(animationForZoomInFromProvider:)])
            //    animation = [toProvider animationForZoomInFromProvider:fromProvider];
        }
    }
    

    [self changeStateTo:state fromState:self.currentState animation:animation canDiffuse:canDiffuse];
}

- (void)setSelectedDate:(NSDate *)date animated:(BOOL)animated
{
    self.selectedDate = date;
    [self updateStateAnimated:animated];
}

- (void)setHighlightedAndSectedDate:(NSDate *)date animated:(BOOL)animated
{
    self.selectedDate = date;
    self.highlightedDate = date;
    [self updateStateAnimated:animated];
}

@end
