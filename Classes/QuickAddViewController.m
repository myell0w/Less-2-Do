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
	// Den delegate vom Less2DoAppDelegate
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	// Den ManagedObjectContext durch den delegate
	NSManagedObjectContext *_context = [delegate managedObjectContext];
	// create a Task
	Task *t = (Task *)[NSEntityDescription 
						  insertNewObjectForEntityForName:@"Task" 
						  inManagedObjectContext:_context]; 
	
	//TODO: parse title and set other attributes (f.e. !!! = Priority 3, !! = Priority 2 ...)
	// filter out priority
	NSRange range = [taskDescription rangeOfString:@"!!!"];
	// !!! not found?
	if (range.location == NSNotFound) {
		range = [title rangeOfString:@"!!"];
	}
	// !! not found?
	if (range.location == NSNotFound) {
		range = [title rangeOfString:@"!"];
	}
	
	// found any priority?
	if (range.location != NSNotFound) {
		t.priority = [[NSNumber alloc] initWithInt:range.length-1];
		[taskDescription deleteCharactersInRange:range];
	} else {
		t.priority = [[NSNumber alloc] initWithInt:PRIORITY_NONE];
	}
	
	// filter out starred
	range = [title rangeOfString:@"*"];
	if (range.location != NSNotFound) {
		t.star = [[NSNumber alloc] initWithBool:YES];
		[taskDescription deleteCharactersInRange:range];
	}
	
	t.name = [taskDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	return t;
}


-(IBAction)taskAdded:(id)sender {
	// send notification to HomeNavigationController --> saves Task and dismisses QuickAddController
	Task *task = [self createTaskFromParsingTitle:taskControl.text];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:task, @"Task", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskQuickAddNotification" object:self userInfo:dict];
	
	[task release];
	[dict release];
}

-(IBAction)taskDetailsEdit:(id)sender {
	// send notification to HomeNavigationController --> opens modal DetailsEdit-Screen
	Task *task = [self createTaskFromParsingTitle:taskControl.text];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:task, @"Task", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskDetailEditNotification" object:self userInfo:dict];
	
	[task release];
	[dict release];
}


@end
