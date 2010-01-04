//
//  TaskEditRecurrenceViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 04.01.10.
//  Copyright 2010 BIAC. All rights reserved.
//

#import "TaskEditRecurrenceViewController.h"


@implementation TaskEditRecurrenceViewController

@synthesize task;
@synthesize pickerData;
@synthesize repeatFrom;
@synthesize repeatEvery;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSArray *array = [[NSArray alloc] initWithObjects:@"No Repeat", @"Weekly", @"Monthly", @"Yearly", @"Daily", @"Biweekly", 
													  @"Bimonthly", @"Semiannually", @"Quarterly", nil];
	
	self.pickerData = array;
	[array release];
	
	if (self.task.repeat != nil) {
		if ([self.task.repeat intValue] >= 100) {
			[repeatFrom setSelectedSegmentIndex:1];
		}
		
		[repeatEvery selectRow:[self.task.repeat intValue]%100 inComponent:0 animated:NO];
	}
	
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	[task release];
	[pickerData release];
	[repeatFrom release];
	[repeatEvery release];
}

- (void)viewWillDisappear:(BOOL)animated {
	int repeat = [repeatEvery selectedRowInComponent:0];
	
	if ([repeatFrom selectedSegmentIndex] == 1)
		repeat += 100;
	
	self.task.repeat = [NSNumber numberWithInt:repeat];
	
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.task = nil;
	self.repeatFrom = nil;
	self.repeatEvery = nil;
	self.pickerData = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Picker Data Source Methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [pickerData count];
}


#pragma mark Picker Delegate Methods

-(NSString *)pickerView:(UIPickerView* )pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [pickerData objectAtIndex:row];
}

@end
