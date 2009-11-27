//
//  EditTaskViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 26.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "EditTaskViewController.h"
#import "CustomCell.h"
#import "TaskEditDueDateViewController.h"
#import "TaskEditDueTimeViewController.h"
#import "UICheckBox.h"


@implementation EditTaskViewController

@synthesize task;

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
	
	self.navigationItem.title = @"Add Task";
	self.navigationItem.leftBarButtonItem = cancel;
	self.navigationItem.rightBarButtonItem = save;
	[save release];
	[cancel release];
	
	
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
}

- (void)dealloc {
	[task release];
    [super dealloc];
}



/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
    
	//int row = [indexPath row];
	//int section = [indexPath section];
    CustomCell *cell = nil;
	NSString *reuseID = nil;
	
	reuseID = [self cellIDForIndexPath:indexPath];	
	cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:reuseID];
	
    if (cell == nil) {
		//TODO: delete if/else
		if ([reuseID isEqualToString:CELL_ID_TITLE]){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID] autorelease];
		} else if ([reuseID isEqualToString:CELL_ID_PRIORITY]) {
			cell = [CustomCell loadFromNib:reuseID withOwner:self];
		} else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID] autorelease];
		}
    }
    
    // Set up the cell...
	if ([reuseID isEqualToString:CELL_ID_TITLE]) {
		// init Title
		CGRect titleLabelRect = CGRectMake(52, 13, 210, 21);
		UITextField *titleText = [[UITextField alloc] initWithFrame:titleLabelRect];
		titleText.font = [UIFont boldSystemFontOfSize:16];
		titleText.returnKeyType = UIReturnKeyDone;
		[titleText setDelegate:self];
		titleText.text = @"Do this and that...";
		[cell.contentView addSubview:titleText];
		[titleText release];
		
		// init Completed-Checkbox
		CGRect completedRect = CGRectMake(9, 6, 32, 32);
		UICheckBox *completedCB = [[UICheckBox alloc] initWithFrame:completedRect];
		[cell.contentView addSubview:completedCB];
		[completedCB release];
		
		// init Starred-Checkbox
		CGRect starredRect = CGRectMake(260, 6, 32, 32);
		UICheckBox *starredCB = [[UICheckBox alloc] initWithFrame:starredRect andOnImage:@"star_on.png" andOffImage:@"star_off.png"];
		[cell.contentView addSubview:starredCB];
		[starredCB release];
		
	} else if ([reuseID isEqualToString:CELL_ID_PRIORITY]) {
		
	} else if ([reuseID isEqualToString:CELL_ID_DUEDATE]) {
		cell.textLabel.text = @"Due Date";
		cell.detailTextLabel.text = @"None";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if ([reuseID isEqualToString:CELL_ID_DUETIME]) {
		cell.textLabel.text = @"Due Time";
		cell.detailTextLabel.text = @"None";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	// set font
	cell.textLabel.font = cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
	
    return cell;
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellID = [self cellIDForIndexPath:indexPath];
	
	// These rows can't be selected:
	if ([cellID isEqualToString:CELL_ID_PRIORITY])
		return nil;
	
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellID = [self cellIDForIndexPath:indexPath];
	
	// if selecting duedate or duetime, push another detail-view controller
	if ([cellID isEqualToString:CELL_ID_DUEDATE]) {
		TaskEditDueDateViewController *ddvc = [[TaskEditDueDateViewController alloc] initWithNibName:@"TaskEditDueDateViewController" bundle:nil];
		[self.navigationController pushViewController:ddvc animated:YES];
		[ddvc release];
	} else if ([cellID isEqualToString:CELL_ID_DUETIME]) {
		TaskEditDueTimeViewController *dtvc = [[TaskEditDueTimeViewController alloc] initWithNibName:@"TaskEditDueTimeViewController" bundle:nil];
		[self.navigationController pushViewController:dtvc animated:YES];
		[dtvc release];
	}
}

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

// save the task
-(IBAction)save:(id)sender {
	
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

// if the user presses "Done" on the Keyboard, hide it
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder]; //dismiss the keyboard
	return YES;
}

@end

