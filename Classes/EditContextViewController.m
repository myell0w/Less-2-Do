//
//  EditContextViewController.m
//  Less2Do
//
//  Created by Philip Messlehner on 11.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditContextViewController.h"
#import "ContextDAO.h"
#import "TasksListViewController.h"

@implementation EditContextViewController
@synthesize nameTextField = _nameTextField;
@synthesize context = _context;
@synthesize parent = _parent;


// Pressing Cancel will pop the actuel View away
- (IBAction) cancel:(id)sender {
	if (self.context == nil)
		[self dismissModalViewControllerAnimated:YES];
	else
		[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) save:(id)sender {
	
	// Update
	if (self.context != nil) {
		
		if([[self.nameTextField text] length]==0) {
			ALog ("Invalid Input");
			return;
		}
		self.context.name = [self.nameTextField text];
		
		
		NSError *error;
		DLog ("Try to update context '%@'", self.context.name);
		if(![ContextDAO updateContext:self.context error:&error]) {
			ALog ("Error occured while updating context");
		}
		else {
			ALog ("context updated");
		}
		
		[self.parent.tableView reloadData];
		[self.navigationController popViewControllerAnimated:YES];
	}
	// Insert
	else {
		// Only Saves when text was entered
		if ([[self.nameTextField text] length] == 0)
			return;
		
		NSError *error;
		self.context = [ContextDAO addContextWithName:[self.nameTextField text] error:&error];
		ALog ("context inserted");
		TasksListViewController *contextView = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
		contextView.title = self.context.name;
		contextView.image = [UIImage imageNamed:@"all_tasks.png"];
		[self.parent.controllersSection1 addObject:contextView];
		[self.parent.list addObject:self.context];
		[contextView release];
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (IBAction) textFieldDone:(id)sender {
	[sender resignFirstResponder];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(ContextsFirstLevelViewController *)aParent context:(Context *)aContext {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.parent = aParent;
		self.context = aContext;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(ContextsFirstLevelViewController *)aParent {
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
	
	if(self.context != nil)
		self.nameTextField.text = self.context.name;
	
	[self.nameTextField becomeFirstResponder];
	
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.nameTextField = nil;
	self.context = nil;
	self.parent = nil;
}


- (void)dealloc {
	[_context release];
	
    [super dealloc];
}


@end