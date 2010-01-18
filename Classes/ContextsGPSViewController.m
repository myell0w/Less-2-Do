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
#import "Less2DoAppDelegate.h"

@implementation ContextsGPSViewController

@synthesize segmentedControl = _segmentedControl;
@synthesize viewContainer = _viewContainer;
@synthesize mapsearchTextField = _mapsearchTextField;
@synthesize overlayView = _overlayView;
@synthesize image = _image;
@synthesize text = _text;
@synthesize mapViewController = _mapViewController;
@synthesize listViewController = _listViewController;
@synthesize locationManager = _locationManager;
@synthesize reverseGeocoder = _reverseGeocoder;
@synthesize location = _location;
@synthesize locationSubTitle = _locationSubTitle;


- (void)viewDidLoad {
	[self.segmentedControl removeFromSuperview];
	
	//add Segmented Control to NavBar
	self.navigationItem.titleView = self.segmentedControl;
	
	//Start LocationManager
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	//init MapView
	self.listViewController = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	self.listViewController.title = @"Nearest Tasks";
	self.listViewController.image = [UIImage imageNamed:@"context_gps.png"];
	self.listViewController.selector = @selector(getTasksWithContext:error:);
	self.listViewController.detailMode = TaskListDetailDistanceMode;
	self.listViewController.currentPosition = self.location;
	CLLocation *locationObject = [[CLLocation alloc] initWithLatitude:self.location.latitude longitude:self.location.longitude];
	self.listViewController.argument = locationObject;
	[locationObject release];
	self.listViewController.parent = self;
	[self.viewContainer insertSubview:self.listViewController.view atIndex:0];
	self.viewContainer.frame = CGRectMake(0, 24, 320, 323);
	
	//Get Location
	[self refreshOwnLocation:nil];
	
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
	[self resignActualFirstResponder];
	ALog("Try to switch Views");
	//try to Switch to ListView
	if([sender selectedSegmentIndex] == 0) {
		if(self.listViewController.view.superview == nil) {
			
			if(self.listViewController.view == nil) {
				self.listViewController = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
				self.listViewController.title = @"Nearest Tasks";
				self.listViewController.image = [UIImage imageNamed:@"context_gps.png"];
				self.listViewController.selector = @selector(getAllTasks:error:);
				CLLocation *locationObject = [[CLLocation alloc] initWithLatitude:self.location.latitude longitude:self.location.longitude];
				self.listViewController.argument = locationObject;
				[locationObject release];
				self.listViewController.detailMode = TaskListDetailDistanceMode;
				self.listViewController.parent = self;
			}
				
			[self.mapViewController.view removeFromSuperview];
			[self.viewContainer insertSubview:self.listViewController.view atIndex:0];
			self.listViewController.currentPosition = self.location;
			[self.listViewController loadData];
			self.viewContainer.frame = CGRectMake(0, 24, 320, 323);
		}
	}
	//Try to Switch to MapView
	else {
		if(self.mapViewController.view.superview == nil) {
			
			if(self.mapViewController.view == nil) {
				self.mapViewController = [[ContextsGPSMapViewController alloc] initWithNibName:@"ContextsGPSMapViewController" bundle:nil parent:self.navigationController];
				self.mapViewController.mapsearchTextField = self.mapsearchTextField;
				ALog ("Generate MapViewController");
				self.mapViewController.annotationSubTitle = self.locationSubTitle;
				
			}
		    [self.mapViewController updateLocation:self.location];
			[self.mapViewController updateAnnotation:self.locationSubTitle];
			[self.listViewController.view removeFromSuperview];
			self.viewContainer.frame = CGRectMake(0, 0, 320, 323);
			[self.viewContainer insertSubview:self.mapViewController.view atIndex:0];
		}
	}

}

- (IBAction)hideMap {
	self.overlayView.hidden = NO;
}

- (IBAction)showMap {
	self.overlayView.hidden = YES;
	[self.mapsearchTextField resignFirstResponder];
}

- (IBAction) refreshOwnLocation:(id)sender {
	Less2DoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate startAnimating];
	[self.locationManager startUpdatingLocation];
}

- (IBAction)resignActualFirstResponder {
	[self.mapsearchTextField resignFirstResponder];
	[self showMap];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CLLocationManagerDelegate Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	ALog ("Location found");
	Less2DoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate stopAnimating];

	
	self.location = newLocation.coordinate;
	
	if(self.mapViewController != nil) {
		[self.mapViewController updateLocation:self.location];
	}
	
	if(self.listViewController != nil) {
		self.listViewController.currentPosition = self.location;
		ALog ("Data loaded");
		[self.listViewController loadData];
	}
	
	[self.locationManager stopUpdatingLocation];
	self.mapsearchTextField.text = @"";
	ALog ("Stop LocationManager");
	
	//Try to ReverseGeocoding
	[self startGeocoder:newLocation.coordinate];
	ALog ("Startet Geocoding");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSString *errorType = (error.code == kCLErrorDenied) ? @"Access Denied" : @"Unknown Error";
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting Location"
													message:errorType delegate:nil
										  cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[alert show];
	[alert release];
	Less2DoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate stopAnimating];
}

- (IBAction) showSearchedLocation {
	//Hide the keypad
	[self resignActualFirstResponder];
	
	//Do nothing when no Text was entered
	if ([[self.mapsearchTextField text] length] == 0)
		return;
	
	NSError *error;	
	NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", 
						   [self.mapsearchTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:&error];
    
	
	self.location = [self addressLocation:locationString];
	if (self.mapViewController != nil) {
		[self.mapViewController updateLocation:self.location];
	}
	
	if (self.listViewController != nil) {
		self.listViewController.currentPosition = self.location;
		[self.listViewController loadData];
	}
	
	//Try to ReverseGeocoding
	[self startGeocoder:self.location];
	ALog ("Started Geocoding");
}

-(CLLocationCoordinate2D) addressLocation:(NSString *)locationString {
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notification and ReverseGeocoding
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)newPlacemark {
	if (self.location.latitude == geocoder.coordinate.latitude &&
		self.location.longitude == geocoder.coordinate.longitude) {
		self.locationSubTitle = [[newPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
		if(self.mapViewController != nil)
			[self.mapViewController updateAnnotation:self.locationSubTitle];
	}
	[self.reverseGeocoder cancel];
	self.reverseGeocoder.delegate = nil;
	self.reverseGeocoder = nil;
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	ALog ("Error during Geocoding");
	
	[self.reverseGeocoder cancel];
	self.reverseGeocoder.delegate = nil;
	self.reverseGeocoder = nil;
}

- (void)startGeocoder:(CLLocationCoordinate2D)location {
	if(self.reverseGeocoder != nil) {
		[self.reverseGeocoder cancel];
		self.reverseGeocoder.delegate = nil;
		self.reverseGeocoder = nil;
	}
	
	self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:location];
	self.reverseGeocoder.delegate = self;
	[self.reverseGeocoder start];
}

@end
