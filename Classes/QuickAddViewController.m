//
//  QuickAddViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 23.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "QuickAddViewController.h"
#import "Less2DoAppDelegate.h"


@implementation QuickAddViewController

@synthesize taskControl;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[taskControl becomeFirstResponder];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.taskControl = nil;
}


- (void)dealloc {
	[taskControl release];
    [super dealloc];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Action-Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (Task *)createTaskFromParsingTitle:(NSString *)title {
	NSMutableString *taskDescription = [[NSMutableString alloc] initWithFormat:title];
	Task *t = (Task *)[Task objectOfType:@"Task"];
	
	//TODO: parse title and set other attributes
	
	// filter out priority ( !!! = High, !! = Medium, ! = Low )
	NSRange range = [taskDescription rangeOfString:@"!!!"];
	// !!! not found?
	if (range.location == NSNotFound) {
		range = [taskDescription rangeOfString:@"!!"];
	}
	// !! not found?
	if (range.location == NSNotFound) {
		range = [taskDescription rangeOfString:@"!"];
	}
	
	// found any priority -> set priority to count of "!" - 1, delete substring from description
	if (range.location != NSNotFound) {
		t.priority = [[NSNumber alloc] initWithInt:range.length-1];
		[taskDescription deleteCharactersInRange:range];
	} else {
		t.priority = [[NSNumber alloc] initWithInt:PRIORITY_NONE];
	}
	
	// filter out starred ( * = Star )
	range = [taskDescription rangeOfString:@"*"];
	if (range.location != NSNotFound) {
		t.star = [[NSNumber alloc] initWithBool:YES];
		[taskDescription deleteCharactersInRange:range];
	}
	
	// filter out dueDate ( #yyyy-mm-dd )
	range = [taskDescription rangeOfString:@"#"];
	if (range.location != NSNotFound) {
		// start with next character and read 10 characters ( = the date in format yyyy-mm-dd)
		range.location++;
		range.length = 10;
		
		// create corresponding dateFormatter
		NSDateFormatter *format = [[NSDateFormatter alloc] init];
		[format setDateFormat: @"yyyy-MM-dd"];
		// get date-string
		NSString *dateString = [taskDescription substringWithRange:range];
		// parse to date
		NSDate *date = [format dateFromString:dateString];
		// reset range-starting position to include "#" and delete date-string from description
		range.location--;
		range.length++;
		[taskDescription deleteCharactersInRange:range];
		
		t.dueDate = date;
		
		//TODO: Messi 4 Matthias
		[format release];
	}
	
	// delete whitespaces at begin and end
	t.name = [taskDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	//TODO: Messi macht die Arbeit für Matthias
	[taskDescription release];
	return t;
}


-(IBAction)taskAdded:(id)sender {
	// send notification to HomeNavigationController --> saves Task and dismisses QuickAddController
	Task *task = [self createTaskFromParsingTitle:taskControl.text];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:task, @"Task", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskQuickAddNotification" object:self userInfo:dict];
	
	[dict release];
}

-(IBAction)taskDetailsEdit:(id)sender {
	// send notification to HomeNavigationController --> opens modal DetailsEdit-Screen
	Task *task = [self createTaskFromParsingTitle:taskControl.text];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:task, @"Task", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskDetailEditNotification" object:self userInfo:dict];
	
	[dict release];
}


@end
