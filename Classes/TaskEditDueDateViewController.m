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
@synthesize dueDate;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self selectionChanged:nil];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.datePicker = nil;
	self.dateLabel = nil;
	self.dueDate = nil;
}

- (void)dealloc {
	[datePicker release];
	[dateLabel release];
	[dueDate release];
	
    [super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Action-Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)selectionChanged:(id)sender {
	self.dueDate = [datePicker date];
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"EEEE, YYYY-MM-dd"];
	
	dateLabel.text = [format stringFromDate:dueDate];
	
	[format release];
}

// set due-date to current date
-(IBAction)setToday {
	NSDate *d = [[NSDate alloc] init];
	
	self.dueDate = d;
	datePicker.date = d;
	[d release];
	
	[self selectionChanged:nil];
}

// set due-date to next day
-(IBAction)setTomorrow {
	NSDate *d = [[NSDate alloc] initWithTimeIntervalSinceNow:60*60*24];
	
	self.dueDate = d;
	datePicker.date = d;
	[d release];
	
	[self selectionChanged:nil];
}

// set due-date to next week
-(IBAction)setNextWeek {
	NSDate *d = [[NSDate alloc] initWithTimeIntervalSinceNow:60*60*24*7];
	
	self.dueDate = d;
	datePicker.date = d;
	[d release];
	
	[self selectionChanged:nil];
}

// set due-date to none
-(IBAction)setNone {
	self.dueDate = nil;
	self.dateLabel.text = @"No Due Date";
}

@end
