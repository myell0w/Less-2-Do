//
//  EditTaskViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 26.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Table-View-Controller for Adding/Editing a Task
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum _TaskControllerMode {
	TaskControllerEditMode,
	TaskControllerAddMode
} TaskControllerMode;

@interface EditTaskViewController : 
			UITableViewController <UIActionSheetDelegate, UITextFieldDelegate, UITableViewDelegate, 
								   UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	// the task to add/edit
	Task *task;
	// temporary data
	NSMutableDictionary *tempData;
	// the text-field being edited
	UITextField *textFieldBeingEdited;
	// the mode in which the controller is in (edit/add)
	TaskControllerMode mode;
	// footer view
	UIView *footerView;
									   
    Folder *oldFolder;
    Context *oldContext;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, retain) Task *task;
@property (nonatomic, retain) NSMutableDictionary *tempData;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;
@property TaskControllerMode mode;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// returns the cellID for a given indexPath
- (NSString *) cellIDForIndexPath:(NSIndexPath *)indexPath;
// action-method for storing the task
- (IBAction)save:(id)sender;
// action-method for aborting the insertion/editing
- (IBAction)cancel:(id)sender;
// priority-value of segmented Control was changed
- (IBAction)priorityValueChanged:(id)sender;
// value of either completed or starred was changed
- (IBAction)checkBoxValueChanged:(id)sender;
// delete a task (only in edit mode)
- (IBAction)deleteTask:(id)sender;
- (IBAction)setImage:(id)sender;

// setUp-Functions for Cells
- (void) setUpTitleCell:(UITableViewCell *)cell;
- (void) setUpPriorityCell:(UITableViewCell *)cell;

@end
