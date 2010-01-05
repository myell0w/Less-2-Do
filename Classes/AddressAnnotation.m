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

@end