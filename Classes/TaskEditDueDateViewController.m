//
//  TaskEditDueDateViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 27.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "TaskEditDueDateViewController.h"


@implementation TaskEditDueDateViewController

@synthesize datePicker;
@synthesize dateLabel;
@synthesize task;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	if (task.dueDate != nil) {
		datePicker.date = task.dueDate;
		NSDateFormatter *format = [[NSDateFormatter alloc] init];
		[format setDateFormat:@"EEEE, YYYY-MM-dd"];
		
		dateLabel.text = [format stringFromDate:task.dueDate];
		[format release];
	} else {
		dateLabel.text = @"No Due Date";
	}
	
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewWillDisappear:(BOOL)animated {
	if (task.dueDate == nil)
		task.dueTime = nil;
	
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.datePicker = nil;
	self.dateLabel = nil;
	self.task = nil;
}

- (void)dealloc {
	[datePicker release];
	[dateLabel release];
	[task release];
	
    [super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Action-Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)changeDate:(NSDate *)d {
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *comp = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit| NSDayCalendarUnit) fromDate:d];
	
	if (self.task.dueTime == nil) {
		[comp setHour:0];
		[comp setMinute:0];
		[comp setSecond:0];
	} else {
		NSDateComponents *timeComp = [cal components:(NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:self.task.dueTime];
		
		[comp setHour:[timeComp hour]];
		[comp setMinute:[timeComp minute]];
		[comp setSecond:[timeComp second]];
	}
	
	task.dueDate = [cal dateFromComponents:comp];
}

-(IBAction)selectionChanged:(id)sender {
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	
	if (sender != nil)
		[self changeDate:[datePicker date]];
	
	[format setDateFormat:@"EEEE, YYYY-MM-dd"];
	dateLabel.text = [format stringFromDate:task.dueDate];
	
	[format release];
}

// set due-date to current date
-(IBAction)setToday {
	NSDate *d = [[NSDate alloc] init];
	
	[self changeDate:d];
	datePicker.date = d;
	[d release];
	
	[self selectionChanged:nil];
}

// set due-date to next day
-(IBAction)setTomorrow {
	NSDate *d = [[NSDate alloc] initWithTimeIntervalSinceNow:60*60*24];
	
	[self changeDate:d];
	datePicker.date = d;
	[d release];
	
	[self selectionChanged:nil];
}

// set due-date to next week
-(IBAction)setNextWeek {
	NSDate *d = [[NSDate alloc] initWithTimeIntervalSinceNow:60*60*24*7];
	
	[self changeDate:d];
	datePicker.date = d;
	[d release];
	
	[self selectionChanged:nil];
}

// set due-date to none
-(IBAction)setNone {
	task.dueDate = nil;
	
	self.dateLabel.text = @"No Due Date";
}

@end
