//
//  AddressAnnotation.m
//  Less2Do
//
//  Created by Philip Messlehner on 04.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddressAnnotation.h"


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark AddressAnnotation-Implementation
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AddressAnnotation

@synthesize title=_title;
@synthesize subtitle=_subtitle;
@synthesize coordinate=_coordinate;
@synthesize context = _context;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	self.coordinate=c;
	NSLog(@"%f,%f",c.latitude,c.longitude);
	return self;
}

+ (MKPinAnnotationView *)viewForAnnotation:(AddressAnnotation *)annotation withColor:(MKPinAnnotationColor)color {
	MKPinAnnotationView *annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AddressAnotation"] autorelease];
	annotationView.canShowCallout = YES;
	
	annotationView.pinColor=color;
	
	return annotationView;
}

+ (MKPinAnnotationView *)viewForAnnotation:(AddressAnnotation *)annotation withColor:(MKPinAnnotationColor)color andContext:(Context *)context{
	MKPinAnnotationView *annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ContextAnotation"] autorelease];
	annotationView.canShowCallout = YES;
	

	annotationView.pinColor=color;
	
	UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	annotationView.rightCalloutAccessoryView = rightButton;	
	
	return annotationView;
}

@end