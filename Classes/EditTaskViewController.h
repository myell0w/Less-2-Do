//
//  EditTaskViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 26.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_ID_TITLE    @"TaskTitleCell"
#define CELL_ID_PRIORITY @"TaskPriorityCell"
#define CELL_ID_DUEDATE  @"TaskDueDateCell"
#define CELL_ID_DUETIME  @"TaskDueTimeCell"
#define CELL_ID_FOLDER   @"TaskFolderCell"
#define CELL_ID_CONTEXT  @"TaskContextCell"
#define CELL_ID_TAGS     @"TaskTagsCell"
#define CELL_ID_NOTES	 @"TaskNotesCell"

#define TAG_TITLE		1
#define TAG_COMPLETED   2
#define TAG_STARRED		3
#define TAG_PRIORITY	4
#define TAG_DUEDATE		5
#define TAG_DUETIME		6
#define TAG_FOLDER      7
#define TAG_CONTEXT		8
#define TAG_TAGS		9
#define TAG_NOTES		10

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Table-View-Controller for Adding/Editing a Task
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum _TaskControllerMode {
	TaskControllerEditMode,
	TaskControllerAddMode
} TaskControllerMode;

@interface EditTaskViewController : UITableViewController <UIActionSheetDelegate, UITextFieldDelegate, UITableViewDelegate> {
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

// setUp-Functions for Cells
- (void) setUpTitleCell:(UITableViewCell *)cell;
- (void) setUpPriorityCell:(UITableViewCell *)cell;

@end
