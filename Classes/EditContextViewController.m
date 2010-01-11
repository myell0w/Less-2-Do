//
//  EditContextViewController.m
//  Less2Do
//
//  Created by Philip Messlehner on 11.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditContextViewController.h"
#import "Context.h"
#import "TasksListViewController.h"

@implementation EditContextViewController
@synthesize nameTextField = _nameTextField;
@synthesize mapsearchTextField = _mapsearchTextField;
@synthesize mapView = _mapView;
@synthesize context = _context;
@synthesize parent = _parent;
@synthesize addAnnotation = _addAnnotation;
@synthesize locationManager = _locationManager;
@synthesize reverseGeocoder = _reverseGeocoder;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
	
	//Start LocationManager
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	self.mapView.delegate = self;
	
	//[self.nameTextField becomeFirstResponder];
	
	if(self.context != nil) {
		self.nameTextField.text = self.context.name;
		if ([self.context hasGps]) {
			MKCoordinateSpan span;
			span.latitudeDelta=0.01;
			span.longitudeDelta=0.01;
			
			
			CLLocationCoordinate2D location;
			location.latitude = [self.context.gpsX doubleValue];
			location.longitude = [self.context.gpsY doubleValue];
			
			MKCoordinateRegion region;
			region.span = span;
			region.center = location;
			
			self.addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:location];
			
			[self.mapView addAnnotation:self.addAnnotation];
			[self.mapView setRegion:region animated:TRUE];
			[self.mapView regionThatFits:region];
			self.mapView.delegate = self;
			
			//Try to ReverseGeocoding
			[self startGeocoder:location];
			ALog ("Startet Geocoding");
		}
	}
	if (self.context == nil || [self.context hasGps] == NO) {
		CLLocationCoordinate2D location;
		location.latitude = 48.209206;
		location.longitude = 16.372778;
		
		MKCoordinateSpan span;
		span.latitudeDelta=20;
		span.longitudeDelta=20;
		
		MKCoordinateRegion region;
		region.span = span;
		region.center = location;
		[self.mapView setRegion:region animated:TRUE];
		[self.mapView regionThatFits:region];
	}
	
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.nameTextField = nil;
	self.context = nil;
	self.parent = nil;
	self.locationManager = nil;
	self.reverseGeocoder = nil;
}


- (void)dealloc {
	[_context release];
	[_locationManager release];
	[_reverseGeocoder release];
    [super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Custom-Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(MKCoordinateSpan) addressSpan:(NSString *)locationString {
	NSArray *listItems = [locationString componentsSeparatedByString:@","];
	MKCoordinateSpan span;
	span.latitudeDelta=20;
	span.longitudeDelta=20;
	
	if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
		if ([[listItems objectAtIndex:1] doubleValue]< 4) {
			span.latitudeDelta = 10;
			span.longitudeDelta = 10;
			
		}
		else {
			span.latitudeDelta = 1 / (([[listItems objectAtIndex:1] doubleValue]+1)*20);
			span.longitudeDelta = 1 / (([[listItems objectAtIndex:1] doubleValue]+1)*20);
		}
		ALog("%f", span.latitudeDelta);
    }
    else {
		ALog("Error occured while searching Location");
    }
	return span;
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

- (BOOL)validAddress:(NSString *)locationString {
	NSArray *listItems = [locationString componentsSeparatedByString:@","];
	
    if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
        return YES;
    }
	return NO;
}

- (void) animateTextField:(UITextField*)textField up:(BOOL)up
{
	int movementDistance = 210;
	if (self.context != nil)
		movementDistance = 210 - 50;
    const float movementDuration = 0.3f;
	
    int movement = (up ? -movementDistance : movementDistance);
	
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Action-Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
		
		if(self.addAnnotation != nil) {
			self.context.gpsX = [NSNumber numberWithDouble:self.addAnnotation.coordinate.latitude];
			self.context.gpsY = [NSNumber numberWithDouble:self.addAnnotation.coordinate.longitude];
		}
		else {
			self.context.gpsX = nil;
			self.context.gpsY = nil;
		}
				
		ALog ("context updated");
		
		[self.parent.tableView reloadData];
		[self.navigationController popViewControllerAnimated:YES];
	}
	// Insert
	else {
		// Only Saves when text was entered
		if ([[self.nameTextField text] length] == 0)
			return;
		
		self.context = (Context *)[BaseManagedObject objectOfType:@"Context"];
		self.context.name = [self.nameTextField text];
		if(self.addAnnotation != nil) {
			self.context.gpsX = [NSNumber numberWithDouble:self.addAnnotation.coordinate.latitude];
			self.context.gpsY = [NSNumber numberWithDouble:self.addAnnotation.coordinate.longitude];
		}
		else {
			self.context.gpsX = nil;
			self.context.gpsY = nil;
		}
		ALog ("context inserted");
		TasksListViewController *contextView = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
		contextView.selector = @selector(getTasksInContext:error:);
		contextView.argument = self.context;
		contextView.title = self.context.name;
		contextView.image = [self.context hasGps] ? [UIImage imageNamed:@"context_gps.png"] : [UIImage imageNamed:@"context_no_gps.png"];
		[self.parent.controllersSection1 addObject:contextView];
		[self.parent.list addObject:self.context];
		[contextView release];
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (IBAction) textFieldDone:(id)sender {
	[self.nameTextField resignFirstResponder];

	if ([self.mapsearchTextField isFirstResponder]) {
		[self animateTextField:self.mapsearchTextField up:NO];
		[self.mapsearchTextField resignFirstResponder];
	}
}

- (IBAction) showSearchedLocation {
	//Hide the keypad
	[self animateTextField:self.mapsearchTextField up:NO];
	[self.mapsearchTextField resignFirstResponder];
	
	//Do nothing when no Text was entered
	if ([[self.mapsearchTextField text] length] == 0)
		return;
	
	MKCoordinateRegion region;
	NSError *error;	
	NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", 
						   [self.mapsearchTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:&error];
    
	
	CLLocationCoordinate2D location = [self addressLocation:locationString];
	region.span = [self addressSpan:locationString];
	region.center=location;
	if(self.addAnnotation != nil) {
		[self.mapView removeAnnotation:self.addAnnotation];
		[self.addAnnotation release];
		_addAnnotation = nil;
	}
	if ([self validAddress:locationString] == YES) {
		self.addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:location];
	}
	else {
		// TODO: Error-Message
	}
	
	[self.mapView addAnnotation:self.addAnnotation];
	[self.mapView setRegion:region animated:TRUE];
	[self.mapView regionThatFits:region];
	
	//Try to ReverseGeocoding
	[self startGeocoder:location];
	ALog ("Started Geocoding");
}

- (IBAction) scrollUp {
	[self animateTextField:self.mapsearchTextField up:YES];
}

- (IBAction) showOwnLocation {
	[self.locationManager startUpdatingLocation];
	ALog ("Start searching for Location");
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CLLocationManagerDelegate Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	ALog ("Location found");
	
	MKCoordinateSpan span;
	span.latitudeDelta=20;
	span.longitudeDelta=20;
	
	MKCoordinateRegion region;
	region.span = span;
	region.center = newLocation.coordinate;
	
	if(self.addAnnotation != nil) {
		[self.mapView removeAnnotation:self.addAnnotation];
		[self.addAnnotation release];
		_addAnnotation = nil;
	}
	
	self.addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:newLocation.coordinate];
	
	[self.mapView addAnnotation:self.addAnnotation];
	[self.mapView setRegion:region animated:TRUE];
	[self.mapView regionThatFits:region];
	
	[self.locationManager stopUpdatingLocation];
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
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	NSLog(@"View for Annotation is called");
	MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"ShowAddressAnotation"];
	if (annotationView == nil) {
		annotationView = [(AddressAnnotation *)annotation viewForAnnotation];
		ALog ("Created View for Annotation");
	}
	else {
		ALog ("Got View for Annotation from Queue");
	}
	
	return annotationView;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notification and ReverseGeocoding
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)newPlacemark {
	if (self.addAnnotation != nil) {
		if (self.addAnnotation.coordinate.latitude == geocoder.coordinate.latitude && self.addAnnotation.coordinate.longitude == geocoder.coordinate.longitude) {
			self.addAnnotation.subtitle = [[newPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
			if ([[self.nameTextField text] length] != 0)
				self.addAnnotation.title = [self.nameTextField text];
			else {
				self.addAnnotation.title = nil;
			}
		}
		ALog ("Finished Geocoding: %@", [[newPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "]);
	}
	[self.mapView selectAnnotation:self.addAnnotation animated:YES];
	[self.reverseGeocoder cancel];
	self.reverseGeocoder.delegate = nil;
	self.reverseGeocoder = nil;
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	if (self.addAnnotation != nil) {
		if (self.addAnnotation.coordinate.latitude == geocoder.coordinate.latitude && self.addAnnotation.coordinate.longitude == geocoder.coordinate.longitude) {
			self.addAnnotation.subtitle = nil;
		}
		ALog ("Error during Geocoding");
	}
	
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

