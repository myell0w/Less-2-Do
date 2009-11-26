//
//  HomeNavigationController.h
//  Less2Do
//
//  Created by Matthias Tretter on 20.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QuickAddViewController;
@class EditTaskViewController;

@interface HomeNavigationController : UINavigationController {
	// View Controller for QuickAdd
	QuickAddViewController *quickAddController;
	// child-view for adding a task
	EditTaskViewController *addTaskController;
}

-(IBAction)addTaskButtonPressed:(id)sender;

@end
