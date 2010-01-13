//
//  ContextsGPSViewController.m
//  Less2Do
//
//  Created by Philip Messlehner on 04.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContextsGPSViewController.h"
#import "ContextsGPSMapViewController.h"
#import "TasksListViewController.h"

@implementation ContextsGPSViewController

@synthesize segmentedControl = _segmentedControl;
@synthesize image = _image;
@synthesize text = _text;
@synthesize mapViewController = _mapViewController;
@synthesize listViewController = _listViewController;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
	[self.segmentedControl removeFromSuperview];
	
	//add Segmented Control to NavBar
	self.navigationItem.titleView = self.segmentedControl;
	
	//init MapView
	self.listViewController = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	self.listViewController.title = @"Nearest Tasks";
	self.listViewController.image = [UIImage imageNamed:@"context_gps.png"];
	self.listViewController.selector = @selector(getTasksWithContext:);
	//self.listViewController.argument = context;
	[self.view insertSubview:self.listViewController.view atIndex:0];
	[self.listViewController loadData];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	if(self.mapViewController.view.superview == nil)
		self.mapViewController = nil;
	else
		self.listViewController = nil;
}

- (void)viewDidUnload {
	self.segmentedControl = nil;
	self.image = nil;
}


- (void)dealloc {
	[_mapViewController release];
	[_listViewController release];
	[_image release];
    [super dealloc];
}

- (IBAction)switchViews:(id)sender {
	ALog("Try to switch Views");
	//try to Switch to ListView
	if([sender selectedSegmentIndex] == 0) {
		if(self.listViewController.view.superview == nil) {
			
			if(self.listViewController.view == nil) {
				self.listViewController = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
				self.listViewController.title = @"Nearest Tasks";
				self.listViewController.image = [UIImage imageNamed:@"context_gps.png"];
				self.listViewController.selector = @selector(getAllTasks:error:);
			}
				
			[self.mapViewController.view removeFromSuperview];
			[self.view insertSubview:self.listViewController.view atIndex:0];
		}
	}
	//Try to Switch to MapView
	else {
		if(self.mapViewController.view.superview == nil) {
			
			if(self.mapViewController.view == nil)
				self.mapViewController = [[ContextsGPSMapViewController alloc] initWithNibName:@"ContextsGPSMapViewController" bundle:nil parent:self.navigationController];
		
			[self.listViewController.view removeFromSuperview];
			[self.view insertSubview:self.mapViewController.view atIndex:0];
		}
	}

}

@end
