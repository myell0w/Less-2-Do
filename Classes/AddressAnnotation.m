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

@synthesize mTitle=_mTitle;
@synthesize mSubTitle=_mSubTitle;
@synthesize coordinate;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	NSLog(@"%f,%f",c.latitude,c.longitude);
	return self;
}

- (NSString *)subtitle{
	return self.mSubTitle;
}
- (NSString *)title{
	if (self.mTitle == nil)
		return @"New Context";
	return self.mTitle;
}

@end