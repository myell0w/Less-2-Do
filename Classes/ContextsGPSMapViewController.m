//
//  ContextsGPSMapViewController.m
//  Less2Do
//
//  Created by Philip Messlehner on 09.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContextsGPSMapViewController.h"
#import "Context.h"
#import "TasksListViewController.h"
#import <MapKit/MapKit.h>
#import <MapKit/MKUserLocation.h>

@implementation ContextsGPSMapViewController
@synthesize parent = _parent;
@synthesize mapView = _mapView;
@synthesize mapsearchTextField = _mapsearchTextField;
@synthesize contexts = _contexts;
@synthesize addAnnotations = _addAnnotations;
@synthesize ownLocation = _ownLocation;
@synthesize ownLocationCoordinate = _ownLocationCoordinate;
@synthesize annotationSubTitle = _annotationSubTitle;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(UINavigationController *)aParent {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.parent = aParent;
    }
    return self;
}

- (void)viewDidLoad {
	self.mapView.delegate = self;
	
	NSError *error;
	self.contexts = [Context getAllContexts:&error];
	
	for (Context *c in self.contexts) {
		//TODO: Only display Contexts with Tasks
		if ([c hasGps]) {
			CLLocationCoordinate2D location;
			location.latitude = [c.gpsX doubleValue];
			location.longitude = [c.gpsY doubleValue];
			
			AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:location];
			addAnnotation.title = c.name;
			addAnnotation.context = c;
			
			
			
			if (addAnnotation.context.tasks != nil) {
				addAnnotation.subtitle = [NSString stringWithFormat:@"%d Tasks", [c.tasks count]];
			} else {
				addAnnotation.subtitle = @"0 Tasks";
			}
			
			
			[self.mapView addAnnotation:addAnnotation];
			[addAnnotation release];
		}
	}
	
	//if(self.ownLocationCoordinate != nil)
		[self updateLocation:self.ownLocationCoordinate];
	
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.contexts = nil;
	self.parent = nil;
}

- (void)dealloc {
	[_contexts release];
    [super dealloc];
}

- (void)updateLocation:(CLLocationCoordinate2D)location {
	self.ownLocationCoordinate = location;
	ALog ("Update Location for Map");
	MKCoordinateRegion region; 
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
}

- (void)updateAnnotation:(NSString *)subTitle {
	if(self.ownLocation != nil) {
		self.ownLocation.subtitle = subTitle;
		self.ownLocation.title = @"Your Location";
	 
		[self.mapView selectAnnotation:self.ownLocation animated:YES];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	NSLog(@"View for Annotation is called");
	MKAnnotationView *annotationView =nil;
	if(((AddressAnnotation *)annotation).context == nil) {
		annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"blueDot"];
		if (annotationView == nil) {
			//annotationView = [AddressAnnotation viewForAnnotation:annotation withColor:MKPinAnnotationColorGreen];
			//annotationView = [[[NSClassFromString(@"MKUserLocationView") alloc] initWithAnnotation:annotation reuseIdentifier:@"blueDot"] autorelease];
			annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"blueDot"] autorelease];
			annotationView.image = [UIImage imageNamed:@"bluedot.png"];
			
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

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	
	if ([control isKindOfClass:[UIButton class]]) {	
		ALog ("AccessoryButton pushed");
		Context *context = ((AddressAnnotation *)view.annotation).context;
		TasksListViewController *contextView = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
		contextView.title = context.name;
		contextView.image = [UIImage imageNamed:@"context_gps.png"];
		contextView.selector = @selector(getTasksInContext:error:);
		contextView.argument = context;
		context = nil;
		
		[self.parent pushViewController:contextView animated:YES];
		[contextView release];
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Hide- and ShowMapFunctions
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@end
