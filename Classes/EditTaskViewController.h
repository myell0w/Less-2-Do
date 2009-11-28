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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Table-View-Controller for Adding/Editing a Task
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface EditTaskViewController : UITableViewController <UIActionSheetDelegate, UITextFieldDelegate> {
	// the task to add/edit
	Task *task;
	// the textfield that stores the title
	UITextField *titleControl;
	// temporary data
	NSDictionary *tempData;
	
	// the segmented-control that stores the priority
	//UISegmentedControl *priorityControl;
	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, retain) Task *task;
@property (nonatomic, retain) UITextField *titleControl;
@property (nonatomic, retain) NSDictionary *tempData;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// returns the cellID for a given indexPath
-(NSString *) cellIDForIndexPath:(NSIndexPath *)indexPath;
// action-method for storing the task
-(IBAction)save:(id)sender;
// action-method for aborting the insertion/editing
-(IBAction)cancel:(id)sender;

@end
