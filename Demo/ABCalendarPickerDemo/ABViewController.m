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
@property (weak, nonatomic) IBOutlet ABCalendarPicker *calendarPicker;
@property (weak, nonatomic) IBOutlet UIImageView * calendarShadow;
@property (weak, nonatomic) IBOutlet UITableView *eventsTable;
@property (weak, nonatomic) IBOutlet UIView *configPanel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configPanelBottomSpace;

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

- (IBAction)configTapped:(id)sender
{
    if (self.configPanelBottomSpace.constant == 0)
        self.configPanelBottomSpace.constant = -self.configPanel.bounds.size.height;
    else
        self.configPanelBottomSpace.constant = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
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
    /*
    self.calendarShadow.frame = CGRectMake(0,CGRectGetMaxY(self.calendarPicker.frame),
                                           self.calendarPicker.frame.size.width,
                                           self.calendarShadow.frame.size.height);
    self.eventsTable.frame = CGRectMake(0, CGRectGetMaxY(self.calendarPicker.frame),
                                        self.eventsTable.bounds.size.width,
                                        self.view.bounds.size.height - self.calendarPicker.bounds.size.height);
     */
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
    
    self.calendarPicker.delegate = self;
    self.calendarPicker.dataSource = self;
    [self calendarPicker:self.calendarPicker animateNewHeight:self.calendarPicker.bounds.size.height];

    //[self configTapped:nil];
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
