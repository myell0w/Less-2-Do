//
//  EditContextViewController.h
//  Less2Do
//
//  Created by Philip Messlehner on 11.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContextsFirstLevelViewController.h"
#import <MapKit/MapKit.h>
#import "AddressAnnotation.h"
#import "MapViewControllerProtocol.h"

@interface EditContextViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate, MKReverseGeocoderDelegate, MapViewControllerProtocol> {
	UITextField *_nameTextField;
	UITextField *_mapsearchTextField;
	Context *_context;   
	ContextsFirstLevelViewController *_parent;
	MKMapView *_mapView;
	AddressAnnotation *_addAnnotation;
	CLLocationManager *_locationManager;
	MKReverseGeocoder *_reverseGeocoder;
}

@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextField *mapsearchTextField;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;
@property (nonatomic, retain) Context *context;
@property (nonatomic, retain) ContextsFirstLevelViewController *parent;
@property (nonatomic, retain) AddressAnnotation *addAnnotation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(ContextsFirstLevelViewController *)aParent context:(Context *)aContext;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(ContextsFirstLevelViewController *)aParent;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
- (IBAction)showSearchedLocation;
- (IBAction) showOwnLocation;
- (IBAction)scrollUp;
- (void) animateTextField:(UITextField*)textField up:(BOOL)up;
- (CLLocationCoordinate2D)addressLocation:(NSString *)locationString;
- (MKCoordinateSpan)addressSpan:(NSString *)locationString;
- (BOOL)validAddress:(NSString *)locationString;
- (void)startGeocoder:(CLLocationCoordinate2D)location;
@end