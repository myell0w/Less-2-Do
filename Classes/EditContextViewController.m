//
//  EditContextViewController.m
//  Less2Do
//
//  Created by Philip Messlehner on 11.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditContextViewController.h"
#import "ContextDAO.h"
#import "TasksListViewController.h"

@implementation EditContextViewController
@synthesize nameTextField = _nameTextField;
@synthesize mapsearchTextField = _mapsearchTextField;
@synthesize mapsearchButton = _mapsearchButton;
@synthesize mapView = _mapView;
@synthesize context = _context;
@synthesize parent = _parent;
@synthesize addAnnotation = _addAnnotation;


- (IBAction) showSearchedLocation {
	//Hide the keypad
	[self.mapsearchTextField resignFirstResponder];
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.001;
	span.longitudeDelta=0.001;
	
	CLLocationCoordinate2D location = [self addressLocation];
	region.span=span;
	region.center=location;
	if(self.addAnnotation != nil) {
		[self.mapView removeAnnotation:self.addAnnotation];
		[self.addAnnotation release];
		_addAnnotation = nil;
	}
	self.addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:location];
	[self.mapView addAnnotation:self.addAnnotation];
	[self.mapView setRegion:region animated:TRUE];
	[self.mapView regionThatFits:region];
}

-(CLLocationCoordinate2D) addressLocation {
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", 
						   [self.mapsearchTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:NULL];
    NSArray *listItems = [locationString componentsSeparatedByString:@","];
	
    double latitude = 48.209206;
    double longitude = 16.372778;
	
    if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
        latitude = [[listItems objectAtIndex:2] doubleValue];
        longitude = [[listItems objectAtIndex:3] doubleValue];
    }
    else {
		ALog("Error occured while searching Location");
    }
    CLLocationCoordinate2D location;
    location.latitude = latitude;
    location.longitude = longitude;
	
    return location;
}


// Pressing Cancel will pop the actuel View away
- (IBAction) cancel:(id)sender {
	if (self.context == nil)
		[self dismissModalViewControllerAnimated:YES];
	else
		[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) save:(id)sender {
	
	// Update
	if (self.context != nil) {
		
		if([[self.nameTextField text] length]==0) {
			ALog ("Invalid Input");
			return;
		}
		self.context.name = [self.nameTextField text];
		
		
		NSError *error;
		DLog ("Try to update context '%@'", self.context.name);
		if(![ContextDAO updateContext:self.context error:&error]) {
			ALog ("Error occured while updating context");
		}
		else {
			ALog ("context updated");
		}
		
		[self.parent.tableView reloadData];
		[self.navigationController popViewControllerAnimated:YES];
	}
	// Insert
	else {
		// Only Saves when text was entered
		if ([[self.nameTextField text] length] == 0)
			return;
		
		NSError *error;
		self.context = [ContextDAO addContextWithName:[self.nameTextField text] error:&error];
		ALog ("context inserted");
		TasksListViewController *contextView = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
		contextView.title = self.context.name;
		contextView.image = [self.context hasGps] ? [UIImage imageNamed:@"context_gps.png"] : [UIImage imageNamed:@"context_no_gps.png"];
		[self.parent.controllersSection1 addObject:contextView];
		[self.parent.list addObject:self.context];
		[contextView release];
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (IBAction) textFieldDone:(id)sender {
	[sender resignFirstResponder];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(ContextsFirstLevelViewController *)aParent context:(Context *)aContext {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.parent = aParent;
		self.context = aContext;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(ContextsFirstLevelViewController *)aParent {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.parent = aParent;
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																	 style:UIBarButtonItemStyleBordered
																	target:self
																	action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
																   style:UIBarButtonItemStyleDone
																  target:self
																  action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	if(self.context != nil)
		self.nameTextField.text = self.context.name;
	
	[self.nameTextField becomeFirstResponder];
	
	//Map-Init
	//mapView = [[MKMapView alloc] initWithFrame:mapViewContainer.view.bounds];
	//[mapViewContainer.view insertSubView:mapView atIndex:0];
	
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.nameTextField = nil;
	self.context = nil;
	self.parent = nil;
}


- (void)dealloc {
	[_context release];
	
    [super dealloc];
}

@end

@implementation AddressAnnotation

@synthesize coordinate;

- (NSString *)subtitle{
	return @"Sub Title";
}

- (NSString *)title{
	return @"Title";
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	NSLog(@"%f,%f",c.latitude,c.longitude);
	return self;
}

@end