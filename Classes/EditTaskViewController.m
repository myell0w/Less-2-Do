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
#import "UICheckBox.h"

#define PRIORITY_RECT CGRectMake(97, 7, 193, 29)
#define TITLE_LABEL_RECT CGRectMake(52, 13, 210, 21)
#define COMPLETED_RECT CGRectMake(9, 6, 32, 32)
#define STARRED_RECT CGRectMake(260, 6, 32, 32)

#define TITLE_FONT_SIZE  15
#define NORMAL_FONT_SIZE 14

@implementation EditTaskViewController

@synthesize task;
@synthesize tempData;
@synthesize textFieldBeingEdited;

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
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//TODO: change
    return 4;
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
	
	// if selecting duedate or duetime, push another detail-view controller
	if ([cellID isEqualToString:CELL_ID_DUEDATE]) {
		TaskEditDueDateViewController *ddvc = [[TaskEditDueDateViewController alloc] 
											   initWithNibName:@"TaskEditDueDateViewController" 
											   bundle:nil];
		ddvc.title = @"Due Date";
		ddvc.task = self.task;
		[self.navigationController pushViewController:ddvc animated:YES];
		[ddvc release];
	} else if ([cellID isEqualToString:CELL_ID_DUETIME]) {
		TaskEditDueTimeViewController *dtvc = [[TaskEditDueTimeViewController alloc] 
											   initWithNibName:@"TaskEditDueTimeViewController" 
											   bundle:nil];
		dtvc.title = @"Due Time";
		dtvc.task = self.task;
		[self.navigationController pushViewController:dtvc animated:YES];
		[dtvc release];
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark ActionSheet-Delegate Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	// if the user really wants to abort, delete the modal view and show the parent view again
	if (buttonIndex != [actionSheet cancelButtonIndex]) {
		[self dismissModalViewControllerAnimated:YES];
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark CUstom Methods
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

