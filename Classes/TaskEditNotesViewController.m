//
//  TaskEditNotesViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 05.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "TaskEditNotesViewController.h"


@implementation TaskEditNotesViewController

@synthesize notes;
@synthesize task;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewWillAppear:(BOOL)animated {
	if (task.note != nil)
		notes.text = task.note;
	
	[notes becomeFirstResponder];
	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self updateNotes];
	
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.notes = nil;
	self.task = nil;
}


- (void)dealloc {
	[notes release];
	[task release];
	
    [super dealloc];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITextView Delegate Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if ([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
		return NO;
	}
	return YES;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Custom Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateNotes {
	task.note = [notes.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


@end
