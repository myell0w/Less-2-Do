//
//  TagDetailController.m
//  Less2Do
//
//  Created by Philip Messlehner on 30.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TagDetailController.h"
#import "TagsFirstLevelController.h"
#import "TasksListViewController.h"
//#import "TagDAO.h"
#import "Tag.h"

@implementation TagDetailController

@synthesize tag;
@synthesize fieldLabels;
@synthesize tempValues;
@synthesize textFieldBeingEdited;

- (id) initWithStyle:(UITableViewStyle)aStyle andTag:(Tag *)aTag {
	if(![super initWithStyle:aStyle])
		return nil;
	
	tag = aTag;
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
	if (tag != nil) {
		for (NSNumber *key in [tempValues allKeys]) {
			switch ([key intValue]) {
				case NAME_ROW_INDEX:
					tag.name = [tempValues objectForKey:key];
					break;
				default:
					break;
			}
		}
		
		NSError *error;
		DLog ("Try to update Tag '%@'", tag.name);
		// TODO: UPDATE
		/*if(![TagDAO updateTag:tag newTag:tag error:&error]) {
			ALog ("Error occured while updating Tag");
		}
		else {
			ALog ("Tag updated");
		}*/
	}
	// Insert
	else {
		NSError *error;
		NSNumber *key = [[NSNumber alloc] initWithInt:NAME_ROW_INDEX];
		NSString *tagName = [tempValues objectForKey:key];
		[key release];
		// TODO: Insert
		//tag = [TagDAO addTagWithName:tagName error:&error];
		
		NSArray *allControllers = self.navigationController.viewControllers;
		
		if ([allControllers count]>1) {
			UIViewController *oneController = [allControllers objectAtIndex:[allControllers count]-2];
			
			if([oneController isKindOfClass:[TagsFirstLevelController class]]) {
				TagsFirstLevelController *parent = (TagsFirstLevelController *) oneController;
				TasksListViewController *tagView = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
				//tagView.title = tag.name;
				tagView.image = [UIImage imageNamed:@"all_tasks.png"];
				//[parent.controllersSection1 addObject:tagView];
				//[parent.list addObject:tag];
				[tagView release];
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
	[tag release];
	[fieldLabels release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return NUMBER_OF_EDITABLE_ROWS;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"TagsEditCellID";
	
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
			else if (tag == nil)
				textField.text = @"New Tag";
			else
				textField.text = tag.name;
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