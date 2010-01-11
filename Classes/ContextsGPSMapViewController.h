//
//  ContextsGPSMapViewController.h
//  Less2Do
//
//  Created by Philip Messlehner on 09.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AddressAnnotation.h"


@interface ContextsGPSMapViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate, MKReverseGeocoderDelegate> {
	NSArray *_contexts;
	MKMapView *_mapView;
	NSArray *_addAnnotations;
	AddressAnnotation *_ownLocation;
	CLLocationManager *_locationManager;
	MKReverseGeocoder *_reverseGeocoder;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;
@property (nonatomic, retain) NSArray *addAnnotations;
@property (nonatomic, retain) AddressAnnotation *ownLocation;
@property (nonatomic, retain) NSArray *contexts;

-(IBAction) showOwnLocation;

@end
