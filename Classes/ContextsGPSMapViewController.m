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
