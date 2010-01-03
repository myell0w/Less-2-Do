//
//  UIColor+ColorComponents.m
//  Less2Do
//
//  Created by Philip Messlehner on 11.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UIColor+ColorComponents.h"


@implementation UIColor (ColorComponents)

- (NSNumber *)redColorComponent {
	CGColorRef color = [self CGColor];
	
	int numComponents = CGColorGetNumberOfComponents(color);
	
	if (numComponents == 4)
	{
		const CGFloat *components = CGColorGetComponents(color);
		CGFloat floatcolor = components[0];
		return [[[NSNumber alloc] initWithFloat:floatcolor] autorelease];
	}
	
	return nil;
}

- (NSNumber *)greenColorComponent {
	CGColorRef color = [self CGColor];
	
	int numComponents = CGColorGetNumberOfComponents(color);
	
	if (numComponents == 4)
	{
		const CGFloat *components = CGColorGetComponents(color);
		CGFloat floatcolor = components[1];
		return [[[NSNumber alloc] initWithFloat:floatcolor] autorelease];
	}
	
	return nil;
}


- (NSNumber *)blueColorComponent {
	CGColorRef color = [self CGColor];
	
	int numComponents = CGColorGetNumberOfComponents(color);
	
	if (numComponents == 4)
	{
		const CGFloat *components = CGColorGetComponents(color);
		CGFloat floatcolor = components[2];
		return [[[NSNumber alloc] initWithFloat:floatcolor] autorelease];
	}
	
	return nil;
}

/*- (NSNumber *) colorComponents {
	UIColor *uicolor = [UIColor redColor];
	CGColorRef color = [self CGColor];
	[uicolor release];
	
	int numComponents = CGColorGetNumberOfComponents(color);
	
	if (numComponents == 4)
	{
		const CGFloat *components = CGColorGetComponents(color);
		CGFloat red = components[0];
		CGFloat green = components[1];
		CGFloat blue = components[2];
		CGFloat alpha = components[3];
		return [[[NSNumber alloc] initWithFloat:red] autorelease];
	}
	
	return nil;
}*/


@end
