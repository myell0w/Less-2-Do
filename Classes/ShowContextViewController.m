//
//  ShowContextViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 04.01.10.
//  Copyright 2010 BIAC. All rights reserved.
//

#import "ShowContextViewController.h"


@implementation ShowContextViewController

@synthesize context;
@synthesize map;

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


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.context = nil;
}


- (void)dealloc {
	[context release];
    [super dealloc];
}


@end
