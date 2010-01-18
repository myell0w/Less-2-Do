//
//  TaskEditImageViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 17.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TaskEditImageViewController.h"
#import "ExtendedInfo.h"


@implementation TaskEditImageViewController

@synthesize task;
@synthesize imageView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if ([task hasImage]) {
		UIImage *img = [[UIImage alloc] initWithData: [self.task imageData]];
		self.imageView.image = img;
		[img release];
	}
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.task = nil;
	self.imageView = nil;
}


- (void)dealloc {
    [super dealloc];
	
	[task release];
	[imageView release];
}

- (IBAction)deleteImage:(id)sender {
	self.task.extendedInfo = nil;
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeImage:(id)sender {
	if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.delegate = self; 
		picker.allowsImageEditing = YES;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; 
		[self presentModalViewController:picker animated:YES];
		[picker release];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing photo library"
														message:@"Device does not support a photo library" delegate:nil
											  cancelButtonTitle:@"Ok!" otherButtonTitles:nil]; 
		[alert show]; 
		[alert release];
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Image Picker Delegate Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image 
				  editingInfo:(NSDictionary *)editingInfo {
	ExtendedInfo *info = (ExtendedInfo *)[self.task.extendedInfo anyObject];
	
	info.type = [NSNumber numberWithInt:EXTENDED_INFO_IMAGE];
	info.data = UIImagePNGRepresentation(image);
	
	imageView.image = image;
	[picker dismissModalViewControllerAnimated:YES];
}


@end
