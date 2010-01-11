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

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	self.coordinate=c;
	NSLog(@"%f,%f",c.latitude,c.longitude);
	return self;
}

-(MKAnnotationView *)viewForAnnotation {
	MKAnnotationView *annotationView = [[[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"ShowAddressAnotation"] autorelease];
	annotationView.canShowCallout = YES;
	
	annotationView.image = [UIImage imageNamed:@"Pin.png"];
	annotationView.centerOffset = CGPointMake(8, -10);
	annotationView.calloutOffset = CGPointMake(-8, 0);
	
	UIImageView *pinShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinShadow.png"]];
	pinShadow.frame = CGRectMake(0, 0, 32, 39);
	pinShadow.hidden = YES;
	[annotationView addSubview:pinShadow];
	[pinShadow release];
	
	return annotationView;
}

@end