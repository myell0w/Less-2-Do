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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editDetails) name:@"TaskDetailEditNotification" object:nil];
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
		// start animation
		[UIView beginAnimations:@"QuickAddAnimationShow" context:nil];
		[UIView setAnimationDuration:0.2];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
		quickAddController = [[QuickAddViewController alloc] initWithNibName:@"QuickAddViewController" bundle:nil];
		quickAddController.view.frame = CGRectMake(0,63,320,44);
		
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:quickAddController.view cache:YES];
		[quickAddController viewWillAppear:YES];		
		[self.view addSubview: quickAddController.view];
		[quickAddController  viewDidAppear:YES];
		
		// end animation
		[UIView commitAnimations];
	} else {
		// start animation
		[UIView beginAnimations:@"QuickAddAnimationHide" context:nil];
		[UIView setAnimationDuration:0.2];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:quickAddController.view cache:YES];
		[quickAddController viewWillDisappear:YES];		
		
		[quickAddController.view removeFromSuperview];
		[quickAddController  viewDidDisappear:YES];
		
		// end animation
		[UIView commitAnimations];
		
		// release memory
		[quickAddController release];
		quickAddController = nil;
	}
	
	
	//addTaskController = [[EditTaskViewController alloc] initWithNibName:@"EditTaskViewController" bundle:nil];
	//addTaskController.title = @"Add Task";
	//[self pushViewController:addTaskController animated:YES];
}

- (IBAction)editDetails {
	// hide quickadd-bar
	if (quickAddController != nil) {
		[quickAddController.view removeFromSuperview];
		[quickAddController release];
		quickAddController = nil;		
	}

	// Present a Model View for adding a Task
	addTaskController = [[EditTaskViewController alloc] initWithNibName:@"EditTaskViewController" bundle:nil];
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:addTaskController];
	[addTaskController release];
	[self presentModalViewController:nc animated:YES];
	[nc release];
}

@end
