//
//  EditTagViewController.m
//  Less2Do
//
//  Created by Philip Messlehner on 10.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditTagViewController.h"
#import "Tag.h"
#import "TasksListViewController.h"
#import "Less2DoAppDelegate.h"

@implementation EditTagViewController
@synthesize nameTextField = _nameTextField;
@synthesize tag = _tag;
@synthesize parent = _parent;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(TagsFirstLevelController *)aParent tag:(Tag *)aTag {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.parent = aParent;
		self.tag = aTag;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(TagsFirstLevelController *)aParent {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.parent = aParent;
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];	
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
	
	if(self.tag != nil)
		self.nameTextField.text = self.tag.name;
	
	[self.nameTextField becomeFirstResponder];
	
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.nameTextField = nil;
	self.tag = nil;
	self.parent = nil;
}

- (void)dealloc {
	[_tag release];
	
    [super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Action-Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Pressing Cancel will pop the actuel View away
- (IBAction) cancel:(id)sender {
	if (self.tag == nil)
		[self dismissModalViewControllerAnimated:YES];
	else
		[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) save:(id)sender {
	
	// Update
	if (self.tag != nil) {
		
		if([[self.nameTextField text] length]==0) {
			ALog ("Invalid Input");
			return;
		}
		self.tag.name = [self.nameTextField text];
		
		ALog ("tag updated");
		
		[self.parent.tableView reloadData];
		[self.navigationController popViewControllerAnimated:YES];
	}
	// Insert
	else {
		// Only Saves when text was entered
		if ([[self.nameTextField text] length] == 0)
			return;
		
		self.tag = (Tag *)[BaseManagedObject objectOfType:@"Tag"];
		self.tag.name = [self.nameTextField text];
		ALog ("tag inserted");
		TasksListViewController *tagView = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
		tagView.selector = @selector(getTasksWithTag:error:);
		tagView.argument = self.tag;
		tagView.title = self.tag.name;
		tagView.image = [UIImage imageNamed:@"tag.png"];
		[self.parent.controllersSection1 addObject:tagView];
		[self.parent.list addObject:self.tag];
		[tagView release];
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (IBAction) textFieldDone:(id)sender {
	[sender resignFirstResponder];
}

@end