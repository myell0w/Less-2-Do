//
//  TaskEditDueTimeViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 27.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "TaskEditDueTimeViewController.h"


@implementation TaskEditDueTimeViewController

@synthesize datePicker;
@synthesize dateLabel;
@synthesize task;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	if (task.dueTime != nil) {
		datePicker.date = task.dueTime;
		NSDateFormatter *format = [[NSDateFormatter alloc] init];
		[format setDateFormat:@"h:mm a"];
		
		dateLabel.text = [format stringFromDate:task.dueTime];
		[format release];
	} else {
		dateLabel.text = @"No Due Time";
	}
	
    [super viewDidLoad];
	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
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
#pragma mark Action Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)changeDate {
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *comp = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit| NSDayCalendarUnit) fromDate:self.task.dueDate];
	
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
	if (sender != nil)
		task.dueTime = [datePicker date];
	[self changeDate];
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"h:mm a"];
	
	dateLabel.text = [format stringFromDate:task.dueTime];
	
	[format release];
}

-(IBAction)setNow {
	NSDate *d = [[NSDate alloc] init];
	
	task.dueTime = d;
	datePicker.date = d;
	[d release];
	
	[self selectionChanged:nil];
}

-(IBAction)setOneHourFromNow {
	NSDate *d = [[NSDate alloc] initWithTimeIntervalSinceNow:60*60];
	
	task.dueTime = d;
	datePicker.date = d;
	[d release];
	
	[self selectionChanged:nil];
}

-(IBAction)setTwoHoursFromNow {
	NSDate *d = [[NSDate alloc] initWithTimeIntervalSinceNow:60*60*2];
	
	task.dueTime = d;
	datePicker.date = d;
	[d release];
	
	[self selectionChanged:nil];
}

-(IBAction)setNone {
	self.task.dueTime = nil;
	self.dateLabel.text = @"No Due Time";
	
	[self changeDate];
}


@end
