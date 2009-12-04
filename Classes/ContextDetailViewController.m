//
//  ContextDetailViewController.m
//  Less2Do
//
//  Created by Philip Messlehner on 26.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ContextDetailViewController.h"
#import "ContextsFirstLevelViewController.h"
#import "TasksListViewController.h"
#import "ContextDAO.h"
#import "Context.h"

@implementation ContextDetailViewController

@synthesize context = _context;
@synthesize fieldLabels = _fieldLabels;
@synthesize tempValues = _tempValues;
@synthesize textFieldBeingEdited = _textFieldBeingEdited;
@synthesize parent = _parent;

- (id) initWithStyle:(UITableViewStyle)aStyle andParent:(ContextsFirstLevelViewController *)aParent andContext:(Context *)aContext {
	if(![super initWithStyle:aStyle])
		return nil;
	
	self.parent = aParent;
	self.context = aContext;
	return self;
}

- (id) initWithStyle:(UITableViewStyle)aStyle andParent:(ContextsFirstLevelViewController *)aParent{
	if(![super initWithStyle:aStyle])
		return nil;
	
	self.parent = aParent;
	return self;
}

// Pressing Cancel will pop the actuel View away
- (IBAction) cancel:(id)sender {
	if (self.context == nil)
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
	if (self.context != nil) {
		NSNumber *key = [[NSNumber alloc] initWithInt:NAME_ROW_INDEX];
		if ([[self.tempValues allKeys] containsObject:key]) {
			if([[self.tempValues objectForKey:key] length]==0) {
				[key release];
				ALog ("Invalid Input");
				return;
			}
			self.context.name = [self.tempValues objectForKey:key];
		}
		[key release];
				
		NSError *error;
		DLog ("Try to update Context '%@'", context.name);
		if(![ContextDAO updateContext:self.context error:&error]) {
			 ALog ("Error occured while updating Context");
		}
		else {
			 ALog ("Context updated");
		}
		
		[self.parent.tableView reloadData];
		[self.navigationController popViewControllerAnimated:YES];
	}
	// Insert
	else {
		// Only Saves when text was entered
		NSNumber *key = [[NSNumber alloc] initWithInt:NAME_ROW_INDEX];
		NSString *contextName = [self.tempValues objectForKey:key];
		[key release];

		if(contextName == nil || [contextName length] == 0)
			return;
		
		NSError *error;
		self.context = [ContextDAO addContextWithName:contextName error:&error];
		ALog ("Context inserted");

		TasksListViewController *contextView = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
		contextView.title = self.context.name;
		contextView.image = [UIImage imageNamed:@"all_tasks.png"];
		[self.parent.controllersSection1 addObject:contextView];
		[self.parent.list addObject:self.context];
		[contextView release];
		[self dismissModalViewControllerAnimated:YES];
	}
}


// Hides the Keyboard after Touching "Done"
- (IBAction) textFieldDone:(id)sender {
	[sender resignFirstResponder];
}

#pragma mark -
- (void) viewDidLoad {
	ALog ("ContextDetailView started didLoad");
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
	
	UIView *textField = [self.tableView viewWithTag:NAME_ROW_INDEX];
	if(textField != nil) {
		ALog ("Textfield found");
		[textField resignFirstResponder];
	}

	[super viewDidLoad];
}

- (void) dealloc {
	[_textFieldBeingEdited release];
	[_tempValues release];
	[_context release];
	[_fieldLabels release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return NUMBER_OF_EDITABLE_ROWS;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"ContextsEditCellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	NSUInteger row = [indexPath row];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10,10,75,25)];
		label.textAlignment = UITextAlignmentRight;
		label.tag = LABEL_TAG;
		label.font = [UIFont boldSystemFontOfSize:14];
		[cell.contentView addSubview:label];
		[label release];
		
		UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
		textField.clearsOnBeginEditing = NO;
		textField.tag = row;
		[textField setDelegate:self];
		textField.returnKeyType = UIReturnKeyDone;
		textField.autocorrectionType = UITextAutocorrectionTypeNo;
		[textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
		[cell.contentView addSubview:textField];
		
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
			else if (self.context != nil)
				textField.text = self.context.name;
			textField.placeholder = @"Enter Context-Name";
			break;
		default:
			break;
	}
	
	if(self.textFieldBeingEdited == textField)
		self.textFieldBeingEdited = nil;
	
	textField.tag = row;
	[rowAsNum release];
	
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
