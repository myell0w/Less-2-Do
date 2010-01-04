//
//  ContextsGPSViewController.h
//  Less2Do
//
//  Created by Philip Messlehner on 04.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ContextsGPSViewController : UIViewController {
	UISegmentedControl *_segmentedControl;
	NSString *_text;
	UIImage *_image;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) UIImage *image;

@end
