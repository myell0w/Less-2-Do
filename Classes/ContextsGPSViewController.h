//
//  ContextsGPSViewController.h
//  Less2Do
//
//  Created by Philip Messlehner on 04.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContextsGPSMapViewController.h"
#import "TasksListViewController.h"


@interface ContextsGPSViewController : UIViewController <CLLocationManagerDelegate, CLLocationManagerDelegate, MKReverseGeocoderDelegate> {
	UISegmentedControl *_segmentedControl;
	NSString *_text;
	UIImage *_image;
	UIView *_viewContainer;
	UITextField *_mapsearchTextField;
	UIView *_overlayView;
	
	ContextsGPSMapViewController *_mapViewController;
	TasksListViewController *_listViewController;
	
	CLLocationManager *_locationManager;
	MKReverseGeocoder *_reverseGeocoder;
	
	CLLocationCoordinate2D _location;
	NSString *_locationSubTitle;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet UIView *viewContainer;
@property (nonatomic, retain) IBOutlet UITextField *mapsearchTextField;
@property (nonatomic, retain) IBOutlet UIView *overlayView;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) UIImage *image;

@property (nonatomic, retain) ContextsGPSMapViewController *mapViewController;
@property (nonatomic, retain) TasksListViewController *listViewController;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;

@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, retain) NSString *locationSubTitle;

- (IBAction) switchViews:(id)sender;
- (IBAction) refreshOwnLocation:(id)sender;
- (IBAction) hideMap;
- (IBAction) showMap;
- (IBAction) showSearchedLocation;
- (IBAction)resignActualFirstResponder;

- (void)startGeocoder:(CLLocationCoordinate2D)location;
- (CLLocationCoordinate2D) addressLocation:(NSString *)locationString;

@end
