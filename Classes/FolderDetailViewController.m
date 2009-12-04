//
//  FolderDetailViewController.m
//  Less2Do
//
//  Created by Philip Messlehner on 30.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FolderDetailViewController.h"
#import "FolderFirstLevelController.h"
#import "TasksListViewController.h"
#import "FolderDAO.h"
#import "Folder.h"

@implementation FolderDetailViewController

@synthesize folder = _folder;
@synthesize fieldLabels = _fieldLabels;
@synthesize tempValues = _tempValues;
@synthesize textFieldBeingEdited = _textFieldBeingEdited;
@synthesize parent = _parent;

- (id) initWithStyle:(UITableViewStyle)aStyle andParent:(FolderFirstLevelController *)aParent andFolder:(Folder *)aFolder {
	if(![super initWithStyle:aStyle])
		return nil;

	self.parent = aParent;
	self.folder = aFolder;
	return self;
}

- (id) initWithStyle:(UITableViewStyle)aStyle andParent:(FolderFirstLevelController *)aParent {
	if(![super initWithStyle:aStyle])
		return nil;
	
	self.parent = aParent;
	return self;
}

// Pressing Cancel will pop the actuel View away
- (IBAction) cancel:(id)sender {
	if (self.folder == nil)
		[self dismissModalViewControllerAnimated:YES];
	else
		[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) save:(id)sender {
	
	// Save was touched while Editing a Textfield -> store the Input in tempValues
	if(self.textFieldBeingEdited != nil) {
		NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:self.textFieldBeingEdited.tag];
		[self.tempValues setObject:self.textFieldBeingEdited.text forKey:tagAsNum];
		[tagAsNum release];
	}
	
	// Update
	if (self.folder != nil) {
		NSNumber *key = [[NSNumber alloc] initWithInt:NAME_ROW_INDEX];
		if ([[self.tempValues allKeys] containsObject:key]) {
			if([[self.tempValues objectForKey:key] length]==0) {
				[key release];
				ALog ("Invalid Input");
				return;
			}
			self.folder.name = [self.tempValues objectForKey:key];
		}
		[key release];
		
		NSError *error;
		DLog ("Try to update Folder '%@'", self.folder.name);
		if(![FolderDAO updateFolder:self.folder error:&error]) {
			ALog ("Error occured while updating Folder");
		}
		else {
			ALog ("Folder updated");
		}
		
		[self.parent.tableView reloadData];
		[self.navigationController popViewControllerAnimated:YES];
	}
	// Insert
	else {
		// Only Saves when text was entered
		NSNumber *key = [[NSNumber alloc] initWithInt:NAME_ROW_INDEX];
		NSString *folderName = [self.tempValues objectForKey:key];
		[key release];
		
		if (folderName == nil || [folderName length] == 0)
			  return;
		
		NSError *error;
		NSNumber *order = [[NSNumber alloc] initWithInt:[self.parent.list count]];
		self.folder = [FolderDAO addFolderWithName:folderName theTasks:nil theOrder:order error:&error];
		ALog ("Folder inserted");
		TasksListViewController *folderView = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
		folderView.title = self.folder.name;
		folderView.image = [UIImage imageNamed:@"all_tasks.png"];
		[self.parent.controllersSection1 addObject:folderView];
		[self.parent.list addObject:self.folder];
		[folderView release];
		[order release];
		[self dismissModalViewControllerAnimated:YES];
	}
}


// Hides the Keyboard after Touching "Done"
- (IBAction) textFieldDone:(id)sender {
	[sender resignFirstResponder];
}

#pragma mark -
- (void) viewDidLoad {
	NSArray *array = [[NSArray alloc] initWithObjects:@"Name:", nil];
	self.fieldLabels = array;
	[array release];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																	 style:UIBarButtonItemStyleBordered
																	target:self
																	action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
																   style:UIBarButtonItemStyleDone
																  target:self
																  action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	self.tempValues = dict;
	[dict release];
	[super viewDidLoad];
}

- (void) dealloc {
	[_textFieldBeingEdited release];
	[_tempValues release];
	[_folder release];
	[_fieldLabels release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return NUMBER_OF_EDITABLE_ROWS;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	UITableViewCell *cell;
	
	// Name Row
	if (row == NAME_ROW_INDEX) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"FoldersTextCellID"];
		
		if (cell == nil) {
			cell = [self createNameCell];
		}
		
		UILabel *label = (UILabel *)[cell viewWithTag:LABEL_TAG];
		UITextField *textField = nil;
		for (UIView *oneView in cell.contentView.subviews) {
			if([oneView isMemberOfClass:[UITextField class]])
				textField = (UITextField *)oneView;
		}
		
		label.text = [self.fieldLabels objectAtIndex:row];
		NSNumber *rowAsNum = [[NSNumber alloc] initWithInt:row];
		
		switch (row) {
			case NAME_ROW_INDEX:
				if([[self.tempValues allKeys] containsObject:rowAsNum])
					textField.text = [self.tempValues objectForKey:rowAsNum];
				else if (self.folder != nil)
					textField.text = self.folder.name;
				textField.placeholder = @"Enter Folder-Name";
				break;
			default:
				break;
		}
		
		if(self.textFieldBeingEdited == textField)
			self.textFieldBeingEdited = nil;
		
		textField.tag = row;
		[rowAsNum release];
	}

	if (row == COLOR_ROW_INDEX) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"FoldersColorCellID"];
		
		if (cell == nil) {
			cell = [self createNameCell];
		}
		
		UILabel *label = (UILabel *)[cell viewWithTag:LABEL_TAG];
		UITextField *textField = nil;
		for (UIView *oneView in cell.contentView.subviews) {
			if([oneView isMemberOfClass:[UITextField class]])
				textField = (UITextField *)oneView;
		}
		
		label.text = [self.fieldLabels objectAtIndex:row];
		NSNumber *rowAsNum = [[NSNumber alloc] initWithInt:row];
		
		
		
		[rowAsNum release];
	}
	
	return cell;
}

- (UITableViewCell *)createNameCell {
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FolderStandardCellID"] autorelease];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10,10,75,25)];
	label.textAlignment = UITextAlignmentRight;
	label.tag = LABEL_TAG;
	label.font = [UIFont boldSystemFontOfSize:14];
	[cell.contentView addSubview:label];
	[label release];
	
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
	textField.clearsOnBeginEditing = NO;
	[textField setDelegate:self];
	textField.returnKeyType = UIReturnKeyDone;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	[textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
	[cell.contentView addSubview:textField];
	return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

#pragma mark Text Field Delegate Methods
- (void) textFieldDidBeginEditing:(UITextField *)textField {
	self.textFieldBeingEdited = textField;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
	NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textField.tag];
	[self.tempValues setObject:textField.text forKey:tagAsNum];
	[tagAsNum release];
}

@end