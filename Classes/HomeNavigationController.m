//
//  HomeNavigationController.m
//  Less2Do
//
//  Created by Matthias Tretter on 20.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "HomeNavigationController.h"
#import "QuickAddViewController.h"
#import "EditTaskViewController.h"


@implementation HomeNavigationController


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
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	// register as observer for Notification sent by QuickAddViewController, when the user want's
	// to edit the details of a QuickAdd-Task --> if so, editDetails: is called
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(editDetails:) 
												 name:@"TaskDetailEditNotification" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(quickAddTask:) 
												 name:@"TaskQuickAddNotification" object:nil];
	
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
	[quickAddController release];
	quickAddController = nil;
	[addTaskController release];
	addTaskController = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
	[quickAddController release];
	[addTaskController release];
	
    [super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Custom Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)addTaskButtonPressed:(id)sender {
	if (quickAddController == nil) {
		quickAddController = [[QuickAddViewController alloc] initWithNibName:@"QuickAddViewController" bundle:nil];
		quickAddController.view.frame = CGRectMake(0,63,320,0);//44);
		
		[self.view addSubview: quickAddController.view];
		
		// start animation
		[UIView beginAnimations:@"QuickAddAnimationShow" context:nil];
		[UIView setAnimationDuration:0.2];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		
		quickAddController.view.frame = CGRectMake(0,63,320,44);
		
		// end animation
		[UIView commitAnimations];
	} else {
		// start animation
		[UIView beginAnimations:@"QuickAddAnimationHide" context:nil];
		[UIView setAnimationDuration:0.2];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		
		quickAddController.view.frame = CGRectMake(0,63,320,0);
		
		// end animation
		[UIView commitAnimations];
		
		// release memory
		[quickAddController.view removeFromSuperview];
		[quickAddController release];
		quickAddController = nil;
	}
}

// is called, when the user want's to edit the details of a QuickAdd-Task
- (IBAction)editDetails:(NSNotification *)notification {
	NSDictionary *dict = [notification userInfo];
	
	// hide quickadd-bar
	if (quickAddController != nil) {
		[quickAddController.view removeFromSuperview];
		[quickAddController release];
		quickAddController = nil;		
	}

	// Present a Model View for adding a Task
	addTaskController = [[EditTaskViewController alloc] initWithNibName:@"EditTaskViewController" bundle:nil];
	addTaskController.task = [[dict objectForKey:@"Task"] retain];
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:addTaskController];
	[addTaskController release];
	[self presentModalViewController:nc animated:YES];
	[nc release];
}

- (IBAction)quickAddTask:(NSNotification *) notification {
	NSDictionary *dict = [notification userInfo];
	Task *task = [[dict objectForKey:@"Task"] retain];
	
	// hide quickadd-bar
	if (quickAddController != nil) {
		[quickAddController.view removeFromSuperview];
		[quickAddController release];
		quickAddController = nil;		
	}
	
	if ([task.name length] > 0) {
		//TODO: store task
		NSError *error;
		ALog("Task to quickadd: %@", task);
		
		[TaskDAO addTask:task error:&error];
	}
}

@end
