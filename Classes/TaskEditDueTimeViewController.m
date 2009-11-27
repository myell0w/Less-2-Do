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
@synthesize dueTime;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self selectionChanged:nil];
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.datePicker = nil;
	self.dateLabel = nil;
	self.dueTime = nil;
}


- (void)dealloc {
	[datePicker release];
	[dateLabel release];
	[dueTime release];
	
    [super dealloc];
}

-(IBAction)selectionChanged:(id)sender {
	self.dueTime = [datePicker date];
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"h:mm a"];
	
	dateLabel.text = [format stringFromDate:dueTime];
	
	[format release];
}

-(IBAction)setNow {
	NSDate *d = [[NSDate alloc] init];
	
	self.dueTime = d;
	datePicker.date = d;
	[d release];
	
	[self selectionChanged:nil];
}

-(IBAction)setOneHourFromNow {
	NSDate *d = [[NSDate alloc] initWithTimeIntervalSinceNow:60*60];
	
	self.dueTime = d;
	datePicker.date = d;
	[d release];
	
	[self selectionChanged:nil];
}

-(IBAction)setTwoHoursFromNow {
	NSDate *d = [[NSDate alloc] initWithTimeIntervalSinceNow:60*60*2];
	
	self.dueTime = d;
	datePicker.date = d;
	[d release];
	
	[self selectionChanged:nil];
}

-(IBAction)setNone {
	self.dueTime = nil;
	self.dateLabel.text = @"No Due Time";
}


@end
