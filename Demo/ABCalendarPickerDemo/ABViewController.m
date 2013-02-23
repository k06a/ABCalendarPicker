//
//  ABViewController.m
//  ABCalendarPickerDemo
//
//  Created by Антон Буков on 19.02.13.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import <ABCalendarPicker/ABCalendarPicker.h>
#import "ABViewController.h"

@interface ABViewController () <ABCalendarPickerDelegateProtocol>
@property (assign, nonatomic) IBOutlet ABCalendarPicker *calendarPicker;
@property (strong, nonatomic) UIImageView * calendarShadow;
@end

@implementation ABViewController

- (UIImageView*)calendarShadow
{
    if (_calendarShadow == nil)
    {
        _calendarShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CalendarShadow"]];
        _calendarShadow.opaque = NO;
    }
    return _calendarShadow;
}

- (IBAction)todayTapped:(id)sender
{
    [self.calendarPicker setDate:[NSDate date] andState:ABCalendarPickerStateDays animated:YES];
}

- (IBAction)monthGridChange:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
        [self.calendarPicker setMonthsProvider:[[ABCalendarPickerDefaultMonthsProvider alloc] init]];
    else
        [self.calendarPicker setMonthsProvider:[[ABCalendarPickerDefaultSeasonedMonthsProvider alloc] init]];
}

- (IBAction)firstWeekdayChange:(UISegmentedControl *)sender
{
    self.calendarPicker.calendar.firstWeekday = (sender.selectedSegmentIndex + 1)%7 + 1;
    [self.calendarPicker updateStateAnimated:YES];
}

- (IBAction)threeWeekChanged:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
        self.calendarPicker.weekdaysProvider = [[ABCalendarPickerDefaultWeekdaysProvider alloc] init];
    else
        self.calendarPicker.weekdaysProvider = [[ABCalendarPickerDefaultTripleWeekdaysProvider alloc] init];
    [self.calendarPicker updateStateAnimated:YES];
}

- (void)calendarPicker:(ABCalendarPicker *)calendarPicker animateNewHeight:(CGFloat)height
{
    self.calendarShadow.frame = CGRectMake(0,CGRectGetMaxY(self.calendarPicker.frame),
                                           self.calendarPicker.frame.size.width,
                                           self.calendarShadow.frame.size.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.calendarPicker.delegate = self;
    [self.view addSubview:self.calendarShadow];
    [self calendarPicker:self.calendarPicker animateNewHeight:self.calendarPicker.bounds.size.height];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCalendarPicker:nil];
    [super viewDidUnload];
}
@end
