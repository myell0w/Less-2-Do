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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// is called, when the "+"-Button in the top-right is clicked (Quickadd/Add new task)
- (IBAction)addTaskButtonPressed:(id)sender;
// is called when the user wants to edit the details of a QuickAdd-Task
- (IBAction)editDetails:(NSNotification *) notification;
// is called when the user wants to add a QuickAdd-Task
- (IBAction)quickAddTask:(NSNotification *) notification;
// hides the quickadd-bar
- (IBAction)hideQuickAdd;
// sync
- (IBAction)syncButtonPressed:(id)sender;
@end

