//
//  TaskEditImageViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 17.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaskEditImageViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	Task *task;
	UIImageView *imageView;
}

@property (nonatomic, retain) Task *task;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

- (IBAction)deleteImage:(id)sender;
- (IBAction)changeImage:(id)sender;

@end
