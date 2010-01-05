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
	
	[self.map setRegion:region animated:TRUE];
	[self.map regionThatFits:region];
	self.map.delegate = self;
	[self.map addAnnotation:self.addAnnotation];
	
	//Try to ReverseGeocoding
	[self startGeocoder:location];
	ALog ("Startet Geocoding");
	[self.map selectAnnotation:self.addAnnotation animated:YES];
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


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	NSLog(@"View for Annotation is called");
	MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"ShowAddressAnotation"];
	if (annotationView == nil) {
		annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ShowAddressAnotation"] autorelease];
		annotationView.canShowCallout = YES;
		
		annotationView.image = [UIImage imageNamed:@"Pin.png"];
		annotationView.centerOffset = CGPointMake(8, -10);
		annotationView.calloutOffset = CGPointMake(-8, 0);
		
		UIImageView *pinShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinShadow.png"]];
		pinShadow.frame = CGRectMake(0, 0, 32, 39);
		pinShadow.hidden = YES;
		[annotationView addSubview:pinShadow];
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
			if ([self.context.name length] != 0)
				self.addAnnotation.title = self.context.name;
			else {
				self.addAnnotation.title = nil;
			}
		}
		ALog ("Finished Geocoding: %@", [[newPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "]);
	}
	[self.map selectAnnotation:self.addAnnotation animated:YES];
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
	[self.map addAnnotation:self.addAnnotation];
	[self.map selectAnnotation:self.addAnnotation animated:YES];
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
