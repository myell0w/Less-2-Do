//
//  ShowContextViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 04.01.10.
//  Copyright 2010 BIAC. All rights reserved.
//

#import "ShowContextViewController.h"
#import "AddressAnnotation.h"

@implementation ShowContextViewController

@synthesize context;
@synthesize map;
@synthesize reverseGeocoder;
@synthesize addAnnotation;

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
	
	[self.map addAnnotation:self.addAnnotation];
	[self.map setRegion:region animated:TRUE];
	[self.map regionThatFits:region];
	
	//Try to ReverseGeocoding
	[self startGeocoder:location];
	ALog ("Startet Geocoding");
	
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.context = nil;
	self.reverseGeocoder = nil;
}


- (void)dealloc {
	[context release];
	[reverseGeocoder release];
    [super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notification and ReverseGeocoding
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)newPlacemark {
	if (self.addAnnotation != nil) {
		if (self.addAnnotation.coordinate.latitude == geocoder.coordinate.latitude && self.addAnnotation.coordinate.longitude == geocoder.coordinate.longitude) {
			self.addAnnotation.mSubTitle = [[newPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
			if ([self.context.name length] != 0)
				self.addAnnotation.mTitle = self.context.name;
			else {
				self.addAnnotation.mTitle = nil;
			}
		}
		ALog ("Finished Geocoding: %@", [[newPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "]);
		[self.map selectAnnotation:self.addAnnotation animated:YES];
	}
	
	[self.reverseGeocoder cancel];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	if (self.addAnnotation != nil) {
		if (self.addAnnotation.coordinate.latitude == geocoder.coordinate.latitude && self.addAnnotation.coordinate.longitude == geocoder.coordinate.longitude) {
			self.addAnnotation.mSubTitle = nil;
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
