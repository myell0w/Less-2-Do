//
//  UICheckBox.m
//  Less2Do
//
//  Created by Matthias Tretter on 26.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "UICheckBox.h"


@implementation UICheckBox

@synthesize onImage;
@synthesize offImage;


- (id)initWithFrame:(CGRect)rect
		andOffImage:(NSString *)offImageName
		 andOnImage:(NSString *)onImageName {
	[super initWithFrame:rect];
	
	UIImage *off = [UIImage imageNamed:offImageName];
	UIImage *on = [UIImage imageNamed:onImageName];
	
	//self.buttonType = UIButtonTypeCustom;
	self.offImage = off;
	self.onImage = on;
	self.selected = FALSE;
	
	[off release];
	[on release];
	
	[self addTarget:self action:@selector(changeSelection:) forControlEvents:UIControlEventTouchUpInside];
	
	return self;
}

- (id)initWithFrame:(CGRect)rect
		andOffImage:(NSString *)offImageName 
		 andOnImage:(NSString *)onImageName andState:(BOOL)state {
	[self initWithFrame:rect andOffImage:offImageName andOnImage:onImageName];
	
	self.selected = state;
	
	return self;
}

-(id)initWithFrame:(CGRect)rect {
	return [self initWithFrame:rect andOffImage:@"Star off" andOnImage:@"Star on"];
}

-(IBAction)changeSelection {
	self.selected = !self.selected;
}

- (void)drawRect:(CGRect)rect {
	if (self.selected) {
		[onImage drawInRect:rect];
	} else {
		[offImage drawInRect:rect];
	}
}

@end
