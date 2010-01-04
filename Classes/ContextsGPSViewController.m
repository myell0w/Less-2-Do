//
//  ContextsGPSViewController.m
//  Less2Do
//
//  Created by Philip Messlehner on 04.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContextsGPSViewController.h"


@implementation ContextsGPSViewController

@synthesize segmentedControl = _segmentedControl;
@synthesize image = _image;
@synthesize text = _text;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
	[self.segmentedControl removeFromSuperview];
	self.navigationItem.titleView = self.segmentedControl;
	ALog ("added SegmentControl to Top");
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.segmentedControl = nil;
	self.image = nil;
}


- (void)dealloc {
	[_image release];
    [super dealloc];
}


@end
