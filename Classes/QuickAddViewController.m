//
//  QuickAddViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 23.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "QuickAddViewController.h"


@implementation QuickAddViewController

@synthesize task;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.view.bounds = CGRectMake(0, 20, 320, 44);
    }
    return self;
} */


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
#pragma mark Action-Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(IBAction)taskAdded:(id)sender {
	//TODO: implement
}

-(IBAction)taskDetailsEdit:(id)sender {
	//TODO: implement
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:task.text, @"Title", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskDetailEditNotification" object:self userInfo:dict];
	
	[dict release];

}


@end
