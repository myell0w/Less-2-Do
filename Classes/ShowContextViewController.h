//
//  ShowContextViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 04.01.10.
//  Copyright 2010 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface ShowContextViewController : UIViewController {
	// the context to show
	Context *context;
	// label to show the context-name
	MKMapView *map;
	
}

@property (nonatomic, retain) Context *context;
@property (nonatomic, retain) IBOutlet MKMapView *map;

@end
