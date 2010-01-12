//
//  ContextsGPSMapViewController.m
//  Less2Do
//
//  Created by Philip Messlehner on 09.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContextsGPSMapViewController.h"
#import "Context.h"
#import <MapKit/MapKit.h>

@implementation ContextsGPSMapViewController
@synthesize mapView = _mapView;
@synthesize mapsearchTextField = _mapsearchTextField;
@synthesize contexts = _contexts;
@synthesize addAnnotations = _addAnnotations;
@synthesize ownLocation = _ownLocation;
@synthesize locationManager = _locationManager;
@synthesize reverseGeocoder = _reverseGeocoder;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
	//Start LocationManager
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	self.mapView.delegate = self;
	[self showOwnLocation];
	
	NSError *error;
	self.contexts = [Context getAllContexts:&error];
	
	for (Context *c in self.contexts) {
		if ([c hasGps]) {
			CLLocationCoordinate2D location;
			location.latitude = [c.gpsX doubleValue];
			location.longitude = [c.gpsY doubleValue];
			
			AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:location];
			addAnnotation.title = c.name;
			addAnnotation.subtitle = @"2 Tasks";
			addAnnotation.context = c;
			
			//addAnnotation.subtitle = [NSString stringWithFormat:@"%@ Tasks", [c.tasks count]];
			
			[self.mapView addAnnotation:addAnnotation];
			[addAnnotation release];
		}
	}
	
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.contexts = nil;
}

- (void)dealloc {
	[_contexts release];
    [super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Action-Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction) showOwnLocation {
	[self.locationManager startUpdatingLocation];
	ALog ("Start searching for Location");
}

- (IBAction) textFieldDone:(id)sender {
	[self.mapsearchTextField resignFirstResponder];
}

- (IBAction) showSearchedLocation {
	//Hide the keypad
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
	MKCoordinateSpan span;
	span.latitudeDelta=0.01;
	span.longitudeDelta=0.01;
	region.span = span;
	region.center=location;
	if(self.ownLocation != nil) {
		[self.mapView removeAnnotation:self.ownLocation];
		[self.ownLocation release];
		_ownLocation = nil;
	}

	self.ownLocation = [[AddressAnnotation alloc] initWithCoordinate:location];
	
	[self.mapView addAnnotation:self.ownLocation];
	[self.mapView setRegion:region animated:TRUE];
	[self.mapView regionThatFits:region];
	
	//Try to ReverseGeocoding
	[self startGeocoder:location];
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
#pragma mark CLLocationManagerDelegate Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	ALog ("Location found");
	
	MKCoordinateSpan span;
	span.latitudeDelta=0.01;
	span.longitudeDelta=0.01;
	
	MKCoordinateRegion region;
	region.span = span;
	region.center = newLocation.coordinate;
	
	if(self.ownLocation != nil) {
		[self.mapView removeAnnotation:self.ownLocation];
		[self.ownLocation release];
		_ownLocation = nil;
	}
	
	self.ownLocation = [[AddressAnnotation alloc] initWithCoordinate:newLocation.coordinate];
	
	[self.mapView addAnnotation:self.ownLocation];
	[self.mapView setRegion:region animated:TRUE];
	[self.mapView regionThatFits:region];
	
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
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	NSLog(@"View for Annotation is called");
	MKPinAnnotationView *annotationView =nil;
	if(((AddressAnnotation *)annotation).context == nil) {
		 annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"AddressAnnotation"];
		if (annotationView == nil) {
			annotationView = [AddressAnnotation viewForAnnotation:annotation withColor:MKPinAnnotationColorGreen];
			ALog ("Created View for Annotation");
		}
		else {
			ALog ("Got View for Annotation from Queue");
		}
	} else {
		annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ContextAnnotation"];
		if (annotationView == nil) {
			annotationView = [AddressAnnotation viewForAnnotation:annotation withColor:MKPinAnnotationColorRed andContext:nil];
			ALog ("Created View for Annotation");
		}
		else {
			ALog ("Got View for Annotation from Queue");
		}
	}
	
	return annotationView;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notification and ReverseGeocoding
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)newPlacemark {
	if (self.ownLocation != nil) {
		if (self.ownLocation.coordinate.latitude == geocoder.coordinate.latitude && self.ownLocation.coordinate.longitude == geocoder.coordinate.longitude) {
			self.ownLocation.subtitle = [[newPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
			self.ownLocation.title = @"Your Location";
		}
		ALog ("Finished Geocoding: %@", [[newPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "]);
	}
	[self.mapView selectAnnotation:self.ownLocation animated:YES];
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
