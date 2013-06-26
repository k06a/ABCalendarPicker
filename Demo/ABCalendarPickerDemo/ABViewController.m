//
//  ABViewController.m
//  ABCalendarPickerDemo
//
//  Created by Антон Буков on 19.02.13.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import <EventKit/EventKit.h>
#import <ABCalendarPicker/ABCalendarPicker.h>
#import "ABViewController.h"

@interface ABViewController () <UITableViewDelegate,UITableViewDataSource,ABCalendarPickerDelegateProtocol,ABCalendarPickerDataSourceProtocol>
@property (assign, nonatomic) IBOutlet ABCalendarPicker *calendarPicker;
@property (strong, nonatomic) UIImageView * calendarShadow;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *eventsTable;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *configPanel;

@property (nonatomic) EKEventStore * store;
@end

@implementation ABViewController

- (EKEventStore *)store
{
    if (_store == nil)
    {
        _store = [[EKEventStore alloc] init];
        if ([[EKEventStore class] resolveClassMethod:@selector(authorizationStatusForEntityType:)])
        {
            if ([EKEventStore authorizationStatusForEntityType:(EKEntityTypeEvent)] != EKAuthorizationStatusAuthorized)
                [_store requestAccessToEntityType:(EKEntityTypeEvent) completion:^(BOOL granted, NSError *error) {
                    ;
                }];
        }
    }
    return _store;
}

- (NSArray *)eventsForDate:(NSDate *)date
{
    NSDateComponents * componentsBegin = [self.calendarPicker.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDateComponents * componentsDay = [[NSDateComponents alloc] init];
    componentsDay.day = 1;
    
    NSDate * dayBegin = [self.calendarPicker.calendar dateFromComponents:componentsBegin];
    NSDate * dayEnd = [self.calendarPicker.calendar dateByAddingComponents:componentsDay toDate:dayBegin options:0];
    
    NSPredicate * predicate = [self.store predicateForEventsWithStartDate:dayBegin endDate:dayEnd calendars:nil];
    return [self.store eventsMatchingPredicate:predicate];
}

- (UIImageView*)calendarShadow
{
    if (_calendarShadow == nil)
    {
        _calendarShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CalendarShadow"]];
        _calendarShadow.opaque = NO;
    }
    return _calendarShadow;
}

- (IBAction)configTapped:(id)sender
{
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         CGFloat y = self.view.bounds.size.height;
                         CGFloat delta = self.configPanel.bounds.size.height / 2;
                         if (self.configPanel.center.y < self.view.bounds.size.height)
                             y += delta;
                         else
                             y -= delta;
                         self.configPanel.center = CGPointMake(self.configPanel.center.x, y);
                     } completion:^(BOOL finished) {
                         self.view.userInteractionEnabled = YES;
                     }];
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

#pragma mark - ABCalendarPicker delegate and dataSource

- (void)calendarPicker:(ABCalendarPicker *)calendarPicker
      animateNewHeight:(CGFloat)height
{
    self.calendarShadow.frame = CGRectMake(0,CGRectGetMaxY(self.calendarPicker.frame),
                                           self.calendarPicker.frame.size.width,
                                           self.calendarShadow.frame.size.height);
    self.eventsTable.frame = CGRectMake(0, CGRectGetMaxY(self.calendarPicker.frame),
                                        self.eventsTable.bounds.size.width,
                                        self.view.bounds.size.height - self.calendarPicker.bounds.size.height);
}

- (NSInteger)calendarPicker:(ABCalendarPicker*)calendarPicker
      numberOfEventsForDate:(NSDate*)date
                    onState:(ABCalendarPickerState)state
{
    if (state != ABCalendarPickerStateDays
        && state != ABCalendarPickerStateWeekdays)
    {
        return 0;
    }
    
    return [[self eventsForDate:date] count];
}

- (void)calendarPicker:(ABCalendarPicker *)calendarPicker
          dateSelected:(NSDate *)date
             withState:(ABCalendarPickerState)state
{
    [self.eventsTable reloadData];
}

#pragma mark - UITableView delegate and dataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSArray * events = [self eventsForDate:self.calendarPicker.highlightedDate];
    return [events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CELL_EVENT"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"CELL_EVENT"];
    
    NSArray * events = [self eventsForDate:self.calendarPicker.highlightedDate];
    EKEvent * event = [events objectAtIndex:indexPath.row];
    
    cell.textLabel.text = event.title;
    cell.detailTextLabel.text = event.notes;
    
    return cell;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.eventsTable.delegate = self;
    self.eventsTable.dataSource = self;
    
    self.calendarPicker.delegate = self;
    self.calendarPicker.dataSource = self;
    [self.view addSubview:self.calendarShadow];
    [self calendarPicker:self.calendarPicker animateNewHeight:self.calendarPicker.bounds.size.height];

    [self configTapped:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCalendarPicker:nil];
    [self setEventsTable:nil];
    [self setConfigPanel:nil];
    [super viewDidUnload];
}
@end
