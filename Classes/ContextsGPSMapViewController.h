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
	UITextField *_mapsearchTextField;
	UINavigationController *_parent;
	UIView *_overlayView;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UITextField *mapsearchTextField;
@property (nonatomic, retain) IBOutlet UIView *overlayView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;
@property (nonatomic, retain) NSArray *addAnnotations;
@property (nonatomic, retain) AddressAnnotation *ownLocation;
@property (nonatomic, retain) NSArray *contexts;
@property (nonatomic, retain) UINavigationController *parent;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(UINavigationController *)aParent;
- (IBAction) showOwnLocation;
- (IBAction) hideMap;
- (IBAction) textFieldDone:(id)sender;
- (IBAction) showSearchedLocation;
- (void)resignActualFirstResponder;
- (void)startGeocoder:(CLLocationCoordinate2D)location;
- (CLLocationCoordinate2D) addressLocation:(NSString *)locationString;

@end
