//
//  EditTaskViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 26.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "EditTaskViewController.h"
#import "TaskEditDueDateViewController.h"
#import "TaskEditDueTimeViewController.h"
#import "TaskEditNotesViewController.h"
#import "TaskEditTagsViewController.h"
#import "TaskEditFolderViewController.h"
#import "TaskEditContextViewController.h"
#import "UICheckBox.h"

#define PRIORITY_RECT CGRectMake(97, 7, 193, 29)
#define TITLE_LABEL_RECT CGRectMake(52, 13, 210, 21)
#define COMPLETED_RECT CGRectMake(9, 6, 32, 32)
#define STARRED_RECT CGRectMake(260, 6, 32, 32)

#define TITLE_FONT_SIZE  15
#define NORMAL_FONT_SIZE 14

#define MAX_NOTE_COUNT 20

@implementation EditTaskViewController

@synthesize task;
@synthesize tempData;
@synthesize textFieldBeingEdited;
@synthesize mode;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
															   style:UIBarButtonItemStylePlain 
															  target:self 
															  action:@selector(cancel:)];
	
	UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" 
															 style:UIBarButtonItemStyleDone
															target:self 
															action:@selector(save:)];
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	self.tempData = dict;
	self.navigationItem.title = @"Add Task";
	self.navigationItem.leftBarButtonItem = cancel;
	self.navigationItem.rightBarButtonItem = save;
	
	[save release];
	[cancel release];
	[dict release];
		
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.task = nil;
	self.tempData = nil;
	self.textFieldBeingEdited = nil;
}

- (void)dealloc {
	[task release];
	[tempData release];
	[textFieldBeingEdited release];
	
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	//TODO:change
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//TODO: change
	if (section == 0)
		return 4;
	else if (section == 1)
		return 3;
	else if (section == 2)
		return 1;
	
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
	NSString *reuseID = nil;
	NSNumber *tagAsNum = nil;
	id tempValue = nil;
	
	reuseID = [self cellIDForIndexPath:indexPath];	
	cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseID];
	
    if (cell == nil) {
		// Init Title-Cell
		if ([reuseID isEqualToString:CELL_ID_TITLE]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID] autorelease];
			[self setUpTitleCell:cell];
		} 
		
		// Init Priority-Cell
		else if ([reuseID isEqualToString:CELL_ID_PRIORITY]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID] autorelease];
			[self setUpPriorityCell:cell];
		} 
		
		// Init Duedate-Cell
		else if ([reuseID isEqualToString:CELL_ID_DUEDATE]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID] autorelease];
			
			cell.textLabel.text = @"Due Date";
			cell.detailTextLabel.text = @"None";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} 
		
		// Init Duetime-Cell
		else if ([reuseID isEqualToString:CELL_ID_DUETIME]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID] autorelease];
			
			cell.textLabel.text = @"Due Time";
			cell.detailTextLabel.text = @"None";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		// Init-Folder-Cell
		else if ([reuseID isEqualToString:CELL_ID_FOLDER]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID] autorelease];
			
			cell.textLabel.text = @"Folder";
			cell.detailTextLabel.text = @"None";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		// Init-Context-Cell
		else if ([reuseID isEqualToString:CELL_ID_CONTEXT]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID] autorelease];
			
			cell.textLabel.text = @"Context";
			cell.detailTextLabel.text = @"None";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		// Init-Tags-Cell
		else if ([reuseID isEqualToString:CELL_ID_TAGS]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID] autorelease];
			
			cell.textLabel.text = @"Tags";
			cell.detailTextLabel.text = @"None";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		// Init-Notes-Cell
		else if ([reuseID isEqualToString:CELL_ID_NOTES]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID] autorelease];
			
			cell.textLabel.text = @"Notes";
			cell.detailTextLabel.text = @"None";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		// set font
		cell.textLabel.font = cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:NORMAL_FONT_SIZE];
    }
    
    // Set up the cell-values ...
	
	if ([reuseID isEqualToString:CELL_ID_TITLE]) {
		// TextField for Title
		UITextField *titleText = (UITextField *)[cell.contentView viewWithTag:TAG_TITLE];
		if (titleText != nil) {
			tagAsNum = [[NSNumber alloc] initWithInt:TAG_TITLE];
			tempValue = [tempData objectForKey:tagAsNum];
			
			if (tempValue != nil) {
				titleText.text = [tempValue description];
			} else {
				titleText.text = task.name;
			}
			
			[tagAsNum release];
		}
		
		
		// Completed-Checkbox
		UICheckBox *completedCB = (UICheckBox *)[cell.contentView viewWithTag:TAG_COMPLETED];
		if (completedCB != nil) {
			tagAsNum = [[NSNumber alloc] initWithInt:TAG_COMPLETED];
			tempValue = [tempData objectForKey:tagAsNum];
			
			if (tempValue != nil) {
				[completedCB setOn:[tempValue boolValue]];
			} else {
				if (task.completionDate != nil || task.isCompleted != nil) {
					[completedCB setOn:YES];
				} else {
					[completedCB setOn:NO];
				}
			}
			
			[tagAsNum release];
		}
		
		// Starred-Checkbox
		UICheckBox *starredCB = (UICheckBox *)[cell.contentView viewWithTag:TAG_STARRED];
		if (starredCB != nil) {
			tagAsNum = [[NSNumber alloc] initWithInt:TAG_STARRED];
			tempValue = [tempData objectForKey:tagAsNum];
			
			if (tempValue != nil) {
				[starredCB setOn:[tempValue boolValue]];
			} else {
				if (task.star != nil) {
					[starredCB setOn:[task.star boolValue]];
				} else {
					[starredCB setOn:NO];
				}
			}
			
			[tagAsNum release];
		}		
	}
	
	else if ([reuseID isEqualToString:CELL_ID_PRIORITY]) {
		// Priority-Segmented-Control
		UISegmentedControl *prioritySC = (UISegmentedControl *)[cell.contentView viewWithTag:TAG_PRIORITY];
		if (prioritySC != nil) {
			tagAsNum = [[NSNumber alloc] initWithInt:TAG_PRIORITY];
			tempValue = [tempData objectForKey:tagAsNum];
			
			if (tempValue != nil) {
				int idx = 2 - [tempValue intValue];
				prioritySC.selectedSegmentIndex = idx > 0 ? idx : 0;
			} else {
				int idx = 2 - [task.priority intValue];
				prioritySC.selectedSegmentIndex = idx > 0 ? idx : 0;
			}		
			[tagAsNum release];
		}		
	}
	
	else if ([reuseID isEqualToString:CELL_ID_DUEDATE]) {
		if (task.dueDate != nil) {
			NSDateFormatter *format = [[NSDateFormatter alloc] init];
			[format setDateFormat:@"EEEE, YYYY-MM-dd"];
			
			cell.detailTextLabel.text = [format stringFromDate:task.dueDate];
			
			[format release];
		} else {
			cell.detailTextLabel.text = @"None";
		}
	}
	
	else if ([reuseID isEqualToString:CELL_ID_DUETIME]) {
		if (task.dueTime != nil) {
			NSDateFormatter *format = [[NSDateFormatter alloc] init];
			[format setDateFormat:@"h:mm a"];
			
			cell.detailTextLabel.text = [format stringFromDate:task.dueTime];
			
			[format release];
		} else {
			cell.detailTextLabel.text = @"None";
		}
	}
	
	else if ([reuseID isEqualToString:CELL_ID_FOLDER]) {
		if (task.folder != nil) {
			cell.detailTextLabel.text = [task.folder description];
		} else {
			cell.detailTextLabel.text = @"None";
		}
	}
	
	else if ([reuseID isEqualToString:CELL_ID_CONTEXT]) {
		if (task.context != nil) {
			cell.detailTextLabel.text = [task.context description];
		} else {
			cell.detailTextLabel.text = @"None";
		}
	}
	
	else if ([reuseID isEqualToString:CELL_ID_TAGS]) {
		if (task.tags != nil && [task.tags count] > 0) {
			NSString *s = [[NSString alloc] initWithFormat:@"%d Tag(s)", [task.tags count]];
			cell.detailTextLabel.text = s;
			[s release];
		} else {
			cell.detailTextLabel.text = @"None";
		}
	}
	
	else if ([reuseID isEqualToString:CELL_ID_NOTES]) {
		if (task.note != nil && [task.note length] > 0) {
			if ([task.note length] > MAX_NOTE_COUNT) {
				NSString *note = [[NSString alloc]initWithFormat:@"%@...", [task.note substringToIndex:MAX_NOTE_COUNT]];
				cell.detailTextLabel.text = note;
				[note release];
			} else {
				cell.detailTextLabel.text = task.note;
			}
		} else {
			cell.detailTextLabel.text = @"None";
		}
	}
	
    return cell;
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellID = [self cellIDForIndexPath:indexPath];
	
	// These rows can't be selected:
	if ([cellID isEqualToString:CELL_ID_TITLE] || [cellID isEqualToString:CELL_ID_PRIORITY])
		return nil;
	
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellID = [self cellIDForIndexPath:indexPath];
	
	//  push another detail-view controller
	if ([cellID isEqualToString:CELL_ID_DUEDATE]) {
		TaskEditDueDateViewController *ddvc = [[TaskEditDueDateViewController alloc] 
											   initWithNibName:@"TaskEditDueDateViewController" 
											   bundle:nil];
		ddvc.title = @"Due Date";
		ddvc.task = self.task;
		[self.navigationController pushViewController:ddvc animated:YES];
		[ddvc release];
	} 
	
	else if ([cellID isEqualToString:CELL_ID_DUETIME]) {
		TaskEditDueTimeViewController *dtvc = [[TaskEditDueTimeViewController alloc] 
											   initWithNibName:@"TaskEditDueTimeViewController" 
											   bundle:nil];
		dtvc.title = @"Due Time";
		dtvc.task = self.task;
		[self.navigationController pushViewController:dtvc animated:YES];
		[dtvc release];
	}
	
	else if ([cellID isEqualToString:CELL_ID_FOLDER]) {
		TaskEditFolderViewController *fvc = [[TaskEditFolderViewController alloc] 
										   initWithNibName:@"TaskEditFolderViewController" 
										   bundle:nil];
		fvc.title = @"Folder";
		fvc.task = self.task;
		[self.navigationController pushViewController:fvc animated:YES];
		[fvc release];
	}
	
	else if ([cellID isEqualToString:CELL_ID_CONTEXT]) {
		TaskEditContextViewController *cvc = [[TaskEditContextViewController alloc] 
										   initWithNibName:@"TaskEditContextViewController" 
										   bundle:nil];
		cvc.title = @"Context";
		cvc.task = self.task;
		[self.navigationController pushViewController:cvc animated:YES];
		[cvc release];
		
	}
	
	else if ([cellID isEqualToString:CELL_ID_TAGS]) {
		TaskEditTagsViewController *tvc = [[TaskEditTagsViewController alloc] 
											   initWithNibName:@"TaskEditTagsViewController" 
											   bundle:nil];
		tvc.title = @"Tags";
		tvc.task = self.task;
		[self.navigationController pushViewController:tvc animated:YES];
		[tvc release];
	}
	
	else if ([cellID isEqualToString:CELL_ID_NOTES]) {
		TaskEditNotesViewController *nvc = [[TaskEditNotesViewController alloc] 
													   initWithNibName:@"TaskEditNotesViewController" 
													   bundle:nil];
		nvc.title = @"Notes";
		nvc.task = self.task;
		[self.navigationController pushViewController:nvc animated:YES];
		[nvc release];
	}	
}

// specify the height of your footer section
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // no footer in add-mode
	if (mode == TaskControllerAddMode) 
		return 0;
	
	return section == 2 ? 60 : 0;
}

// custom view for footer. will be adjusted to default or specified footer height
// Notice: this will work only for one section within the table view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if(footerView == nil && mode == TaskControllerEditMode) {
        //allocate the view if it doesn't exist yet
        footerView  = [[UIView alloc] init];
		
        //we would like to show a gloosy red button, so get the image first
        UIImage *image = [[UIImage imageNamed:@"button_red.png"]
						  stretchableImageWithLeftCapWidth:8 topCapHeight:8];
		
        //create the button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setBackgroundImage:image forState:UIControlStateNormal];
		
        //the button should be as big as a table view cell
        [button setFrame:CGRectMake(10, 10, 300, 44)];
		
        //set title, font size and font color
        [button setTitle:@"Delete Task" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		
        //set action of the button
        [button addTarget:self action:@selector(deleteTask:)
		 forControlEvents:UIControlEventTouchUpInside];
		
        //add the button to the view
        [footerView addSubview:button];
    }
	
    //return the view for the footer
    return footerView;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark ActionSheet-Delegate Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	// Action-Sheet to cancel add-action?
	if ([actionSheet.title isEqualToString:@"Really Cancel?"]) {
		// if the user really wants to abort, delete the modal view and show the parent view again
		if (buttonIndex != [actionSheet cancelButtonIndex]) {
			[self dismissModalViewControllerAnimated:YES];
		}
	}
	// Action-Sheet to delete a task?
	else if ([actionSheet.title isEqualToString:@"Delete Task?"]) {
		// if the user really wants to delete a task...
		if (buttonIndex != [actionSheet cancelButtonIndex]) {
			//TODO: delete task
		}
	}
				 
}
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TextField-Delegate Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// store currenty edited textfield
// needed, when the user is currently editing a textfield and then presses save to retrieve its value
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.textFieldBeingEdited = textField;
}


// temporary store changed values in Dictionary (to keep old data stored in task)
- (void)textFieldDidEndEditing:(UITextField *)textField {
	NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textField.tag];	
	
	[tempData setObject:textField.text forKey:tagAsNum];	
	ALog("Temporary Value stored in Dict: %@ = %@", tagAsNum, textField.text);
	
	[tagAsNum release];
}

// if the user presses "Done" on the Keyboard, hide it
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder]; //dismiss the keyboard
	return YES;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Action-Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// temporary store changed values in Dictionary (to keep old data stored in task)
- (IBAction)priorityValueChanged:(id)sender {
	UISegmentedControl *sc = (UISegmentedControl *)sender;
	
	NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:sc.tag];	
	NSNumber *value = [[NSNumber alloc] initWithInt:2-sc.selectedSegmentIndex];
	
	[tempData setObject:value forKey:tagAsNum];	
	ALog("Temporary Value stored in Dict: %@ = %@", tagAsNum, value);
	
	[tagAsNum release];
	[value release];	
}

// temporary store changed values in Dictionary (to keep old data stored in task)
- (IBAction)checkBoxValueChanged:(id)sender {
	UICheckBox *cb = (UICheckBox *)sender;
	
	NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:cb.tag];	
	NSNumber *value = [[NSNumber alloc] initWithBool:[cb isOn]];
	
	[tempData setObject:value forKey:tagAsNum];	
	ALog("Temporary Value stored in Dict: %@ = %@", tagAsNum, value);
	
	[tagAsNum release];
	[value release];
}

// save the task
-(IBAction)save:(id)sender {
	NSError *error = nil;
	
	// TODO:
	if (textFieldBeingEdited != nil) {
		NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textFieldBeingEdited.tag];
		[tempData setObject:textFieldBeingEdited.text forKey:tagAsNum];
		[tagAsNum release];
	}
	
	for (NSNumber *key in [tempData allKeys]) {
		if ([key intValue] == TAG_TITLE) {
			task.name = [tempData objectForKey:key];
		} else if ([key intValue] == TAG_STARRED) {
			task.star = [tempData objectForKey:key];
		} else if ([key intValue] == TAG_COMPLETED) {
			if ([[tempData objectForKey:key] boolValue]) {
				task.completionDate = [[NSDate alloc] init];
				task.isCompleted = [[NSNumber alloc] initWithBool:YES];
			} else {
				task.isCompleted = [[NSNumber alloc] initWithBool:NO];
			}
		} else if ([key intValue] == TAG_PRIORITY) {
			task.priority = [tempData objectForKey:key];
		} else if ([key intValue] == TAG_DUEDATE) {
			task.dueDate = [tempData objectForKey:key];
		} else if ([key intValue] == TAG_DUETIME) {
			task.dueTime = [tempData objectForKey:key];
		} else if ([key intValue] == TAG_FOLDER) {
			task.folder = [tempData objectForKey:key];
		} else if ([key intValue] == TAG_CONTEXT) {
			task.context = [tempData objectForKey:key];
		} else if ([key intValue] == TAG_TAGS) {
			task.tags = [tempData objectForKey:key];
		} else if ([key intValue] == TAG_NOTES) {
			task.note = [tempData objectForKey:key];
		}
	}
	
	ALog("Task to save: %@", task);
	[TaskDAO addTask:task error:&error];
	
	//TODO:error handling
	ALog("Task was saved!");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskAddedNotification" object:self];
	
	[self dismissModalViewControllerAnimated:YES];
}

// cancel the adding/editing
-(IBAction)cancel:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Really Cancel?"
															 delegate:self
													cancelButtonTitle:@"No"
											   destructiveButtonTitle:@"Yes"
													otherButtonTitles:nil];
	
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (IBAction)deleteTask:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Task?"
															 delegate:self
													cancelButtonTitle:@"Don't Delete"
											   destructiveButtonTitle:@"Delete"
													otherButtonTitles:nil];
	
	[actionSheet showInView:self.view];
	[actionSheet release];
	
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Custom Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString *) cellIDForIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	int section = [indexPath section];
	
	if (section == 0 && row == 0)
		return CELL_ID_TITLE;
	else if (section == 0 && row == 1)
		return CELL_ID_PRIORITY;
	else if (section == 0 && row == 2)
		return CELL_ID_DUEDATE;
	else if (section == 0 && row == 3)
		return CELL_ID_DUETIME;
	
	else if (section == 1 && row == 0)
		return CELL_ID_FOLDER;
	else if (section == 1 && row == 1)
		return CELL_ID_CONTEXT;
	else if (section == 1 && row == 2)
		return CELL_ID_TAGS;
	
	else if (section == 2 && row == 0)
		return CELL_ID_NOTES;
	
	return nil;
}

- (void) setUpTitleCell:(UITableViewCell *)cell {
	// init Textfield for Title
	UITextField *titleText = [[UITextField alloc] initWithFrame:TITLE_LABEL_RECT];
	titleText.font = [UIFont boldSystemFontOfSize:TITLE_FONT_SIZE];
	titleText.placeholder = @"Enter Task-Title...";
	titleText.returnKeyType = UIReturnKeyDone;
	titleText.autocorrectionType = UITextAutocorrectionTypeNo;
	titleText.tag = TAG_TITLE;
	[titleText setDelegate:self];
	// add Textfield to Cell
	[cell.contentView addSubview:titleText];
	[titleText release];
	
	// init Completed-Checkbox
	UICheckBox *completedCB = [[UICheckBox alloc] initWithFrame:COMPLETED_RECT];
	completedCB.tag = TAG_COMPLETED;
	[completedCB addTarget:self 
					action:@selector(checkBoxValueChanged:) 
		  forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:completedCB];
	[completedCB release];
	
	// init Starred-Checkbox
	UICheckBox *starredCB = [[UICheckBox alloc] initWithFrame:STARRED_RECT 
												   andOnImage:@"star_on.png" 
												  andOffImage:@"star_off.png"];
	starredCB.tag = TAG_STARRED;
	[starredCB addTarget:self 
				  action:@selector(checkBoxValueChanged:) 
		forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:starredCB];
	[starredCB release];
}

- (void)setUpPriorityCell:(UITableViewCell *)cell {
	// init segmented-control
	NSArray *img = [[NSArray alloc] 
					initWithObjects:[UIImage imageNamed:@"priority_3.png"],
					[UIImage imageNamed:@"priority_2.png"],
					[UIImage imageNamed:@"priority_1.png"],
					[UIImage imageNamed:@"priority_0.png"],nil];
	UISegmentedControl *priorityControl = [[UISegmentedControl alloc] initWithItems:img];
	priorityControl.frame = PRIORITY_RECT;
	priorityControl.segmentedControlStyle = UISegmentedControlStyleBar;
	priorityControl.selectedSegmentIndex = 3;
	priorityControl.tag = TAG_PRIORITY;
	
	[priorityControl addTarget:self
						action:@selector(priorityValueChanged:)
			  forControlEvents:UIControlEventValueChanged];
	// add to cell
	cell.textLabel.text = @"Priority";
	[cell.contentView addSubview:priorityControl];
	[priorityControl release];
}

@end

