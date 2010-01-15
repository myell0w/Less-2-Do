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

@interface ContextsGPSMapViewController : UIViewController<MKMapViewDelegate> {
	NSArray *_contexts;
	MKMapView *_mapView;
	NSArray *_addAnnotations;
	AddressAnnotation *_ownLocation;
	CLLocationCoordinate2D _ownLocationCoordinate;
	NSString *_annotationSubTitle;

	UITextField *_mapsearchTextField;
	UINavigationController *_parent;
	
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) UITextField *mapsearchTextField;
@property (nonatomic) CLLocationCoordinate2D ownLocationCoordinate;
@property (nonatomic, retain) NSString *annotationSubTitle;

@property (nonatomic, retain) NSArray *addAnnotations;
@property (nonatomic, retain) AddressAnnotation *ownLocation;
@property (nonatomic, retain) NSArray *contexts;
@property (nonatomic, retain) UINavigationController *parent;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(UINavigationController *)aParent;
- (void)updateLocation:(CLLocationCoordinate2D)location;
- (void)updateAnnotation:(NSString *)subTitle;

@end
