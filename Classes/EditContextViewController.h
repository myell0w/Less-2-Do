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

@interface AddressAnnotation : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	//NSString *mTitle;
	//NSString *mSubTitle;
}
@end

@interface EditContextViewController : UIViewController<MKMapViewDelegate> {
	UITextField *_nameTextField;
	UITextField *_mapsearchTextField;
	UIButton *_mapsearchButton;
	Context *_context;   
	ContextsFirstLevelViewController *_parent;
	MKMapView *_mapView;
	AddressAnnotation *_addAnnotation;
}

@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextField *mapsearchTextField;
@property (nonatomic, retain) IBOutlet UIButton *mapsearchButton;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) Context *context;
@property (nonatomic, retain) ContextsFirstLevelViewController *parent;
@property (nonatomic, retain) AddressAnnotation *addAnnotation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(ContextsFirstLevelViewController *)aParent context:(Context *)aContext;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(ContextsFirstLevelViewController *)aParent;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
- (IBAction)showSearchedLocation;
- (CLLocationCoordinate2D)addressLocation:(NSString *)locationString;
- (MKCoordinateSpan)addressSpan:(NSString *)locationString;
- (BOOL)validAddress:(NSString *)locationString;
@end