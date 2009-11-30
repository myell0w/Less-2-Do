//
//  ContextDetailController.m
//  Less2Do
//
//  Created by Philip Messlehner on 26.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ContextDetailController.h"
#import "ContextsFirstLevelViewController.h"
#import "TasksListViewController.h"
#import "ContextDAO.h"
#import "Context.h"

@implementation ContextDetailController

@synthesize context;
@synthesize fieldLabels;
@synthesize tempValues;
@synthesize textFieldBeingEdited;

- (id) initWithStyle:(UITableViewStyle)aStyle andContext:(Context *)aContext {
	if(![super initWithStyle:aStyle])
		return nil;
	
	context = aContext;
	return self;
}

// Pressing Cancel will pop the actuel View away
- (IBAction) cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) save:(id)sender {
	
	// Save was touched while Editing a Textfield -> store the Input in tempValues
	if(textFieldBeingEdited != nil) {
		NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textFieldBeingEdited.tag];
		[tempValues setObject:textFieldBeingEdited.text forKey:tagAsNum];
		[tagAsNum release];
	}
	
	// Update
	if (context != nil) {
		for (NSNumber *key in [tempValues allKeys]) {
			switch ([key intValue]) {
				case NAME_ROW_INDEX:
					context.name = [tempValues objectForKey:key];
					break;
				default:
					break;
			}
		}
		
		NSError *error;
		DLog ("Try to update Context '%@'", context.name);
		if(![ContextDAO updateContext:context newContext:context error:&error]) {
			 ALog ("Error occured while updating Context");
		}
		else {
			 ALog ("Context updated");
		}
	}
	// Insert
	else {
		NSError *error;
		NSNumber *key = [[NSNumber alloc] initWithInt:NAME_ROW_INDEX];
		NSString *contextName = [tempValues objectForKey:key];
		[key release];
		context = [ContextDAO addContextWithName:contextName error:&error];
		
		NSArray *allControllers = self.navigationController.viewControllers;
		
		if ([allControllers count]>1) {
			UIViewController *oneController = [allControllers objectAtIndex:[allControllers count]-2];
			
			if([oneController isKindOfClass:[ContextsFirstLevelViewController class]]) {
				ContextsFirstLevelViewController *parent = (ContextsFirstLevelViewController *) oneController;
				TasksListViewController *contextView = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
				contextView.title = context.name;
				contextView.image = [UIImage imageNamed:@"all_tasks.png"];
				[parent.controllersSection1 addObject:contextView];
				[parent.list addObject:context];
				[contextView release];
			}
		}
		
	}
	
	[self.navigationController popViewControllerAnimated:YES];
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
	[textFieldBeingEdited release];
	[tempValues release];
	[context release];
	[fieldLabels release];
	
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
		[textField setDelegate:self];
		textField.returnKeyType = UIReturnKeyDone;
		[textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
		[cell.contentView addSubview:textField];
		
	}
	
	NSUInteger row = [indexPath row];	
	
	UILabel *label = (UILabel *)[cell viewWithTag:LABEL_TAG];
	UITextField *textField = nil;
	for (UIView *oneView in cell.contentView.subviews) {
		if([oneView isMemberOfClass:[UITextField class]])
			textField = (UITextField *)oneView;
	}
	
	label.text = [fieldLabels objectAtIndex:row];
	NSNumber *rowAsNum = [[NSNumber alloc] initWithInt:row];
	
	switch (row) {
		case NAME_ROW_INDEX:
			if([[tempValues allKeys] containsObject:rowAsNum])
				textField.text = [tempValues objectForKey:rowAsNum];
			else if (context == nil)
				textField.text = @"New Context";
			else
				textField.text = context.name;
			break;
		default:
			break;
	}
	
	if(textFieldBeingEdited == textField)
		textFieldBeingEdited = nil;
	
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
	[tempValues setObject:textField.text forKey:tagAsNum];
	[tagAsNum release];
}

@end
