//
//  EditFolderViewController.m
//  Less2Do
//
//  Created by Philip Messlehner on 08.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditFolderViewController.h"
#import "FolderDAO.h"
#import "TasksListViewController.h"


@implementation EditFolderViewController
@synthesize nameTextField = _nameTextField;
@synthesize folder = _folder;
@synthesize parent = _parent;


// Pressing Cancel will pop the actuel View away
- (IBAction) cancel:(id)sender {
	if (self.folder == nil)
		[self dismissModalViewControllerAnimated:YES];
	else
		[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) save:(id)sender {
	
	// Update
	if (self.folder != nil) {
		
		if([[self.nameTextField text] length]==0) {
			ALog ("Invalid Input");
			return;
		}
		self.folder.name = [self.nameTextField text];
		
		
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
		if ([[self.nameTextField text] length] == 0)
			return;
		
		NSError *error;
		NSNumber *order = [[NSNumber alloc] initWithInt:[self.parent.list count]];
		self.folder = [FolderDAO addFolderWithName:[self.nameTextField text] theTasks:nil theOrder:order error:&error];
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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(FolderFirstLevelController *)aParent folder:(Folder *)aFolder {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.parent = aParent;
		self.folder = aFolder;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(FolderFirstLevelController *)aParent {
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
	[super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.nameTextField = nil;
	self.folder = nil;
	self.parent = nil;
}


- (void)dealloc {
	[_nameTextField dealloc];
	[_folder release];
	[_parent release];
	
    [super dealloc];
}


@end
