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
#import "SyncManager.h"


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
		// move table view down (44 px)
		((UITableViewController *)self.topViewController).tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
		
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
		[self hideQuickAdd];
	}
}

// is called, when the user want's to edit the details of a QuickAdd-Task
- (IBAction)editDetails:(NSNotification *)notification {
	NSDictionary *dict = [notification userInfo];
	
	[self hideQuickAdd];
	
	// Present a Model View for adding a Task
	addTaskController = [[EditTaskViewController alloc] initWithNibName:@"EditTaskViewController" bundle:nil];
	addTaskController.task = [[dict objectForKey:@"Task"] retain];
	addTaskController.mode = TaskControllerAddMode;
	addTaskController.title = @"Add Task";
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:addTaskController];
	[addTaskController release];
	[self presentModalViewController:nc animated:YES];
	[nc release];
}

- (IBAction)quickAddTask:(NSNotification *) notification {
	NSDictionary *dict = [notification userInfo];
	Task *task = [[dict objectForKey:@"Task"] retain];
	
	// hide quickadd-bar
	[self hideQuickAdd];
	
	if ([task.name length] > 0) {
		ALog("Task to quickadd: %@", task);
		
		Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		delegate.currentEditedTask = nil;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskAddedNotification" object:nil];
	}
	[task release];
}

- (IBAction)hideQuickAdd {
	// hide quickadd-bar
	if (quickAddController != nil) {
		((UITableViewController *)self.topViewController).tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
		
		[quickAddController.view removeFromSuperview];
		[quickAddController release];
		quickAddController = nil;		
	}	
}

-(IBAction)syncButtonPressed:(id)sender 
{
	NSError *error = nil;
	
	Less2DoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate startAnimating];
	
	
	SyncManager *syncManager = [[SyncManager alloc] init];
	Setting *settings = [Setting getSettings:&error];
	NSString *stopTitle = nil;
	NSString *stopMessage = nil;
	if(error == nil)
	{
		BOOL successful = NO;
		if([settings.preferToodleDo boolValue])
			successful = [syncManager syncWithPreference:SyncPreferRemote error:&error];
		else
			successful = [syncManager syncWithPreference:SyncPreferLocal error:&error];

		if(!successful)
		{
			stopTitle = @"Error";
			stopMessage = [SyncManager gtdErrorMessage:[error code]];
			ALog(@"Error syncWithPreference:SyncPreferLocal = %@: %@", [SyncManager gtdErrorMessage:[error code]], error);
		}
		else
		{
			stopTitle = @"Success";
			stopMessage = @"Sync with ToodleDo was successful";
			ALog(@"syncWithPreference:SyncPreferLocal was successful");
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskAddedNotification" object:nil];
	}
	else {
		stopTitle = @"Error";
		stopMessage = @"Could not retrieve Toodledo account settings";
	}

	[appDelegate stopAnimatingWithTitle:stopTitle andMessage:stopMessage];
	[syncManager release];
}

@end
