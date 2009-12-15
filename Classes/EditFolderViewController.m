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
#import "UIColor+ColorComponents.h"

@implementation EditFolderViewController
@synthesize nameTextField = _nameTextField;
@synthesize folder = _folder;
@synthesize parent = _parent;
@synthesize color = _color;

// Pressing Cancel will pop the actuel View away
- (IBAction) cancel:(id)sender {
	if (self.folder == nil)
		[self dismissModalViewControllerAnimated:YES];
	else
		[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) save:(id)sender 
{
	
	// Update
	if (self.folder != nil) {
		
		if([[self.nameTextField text] length]==0) {
			ALog ("Invalid Input");
			return;
		}
		self.folder.name = [self.nameTextField text];

		self.folder.r = [self.color redColorComponent];
		self.folder.g = [self.color greenColorComponent];
		self.folder.b = [self.color blueColorComponent];
		
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
		[self.color colorComponents];
		self.folder.r = [self.color redColorComponent];
		self.folder.g = [self.color greenColorComponent];
		self.folder.b = [self.color blueColorComponent];
		DLog ("Try to update Folder '%@'", self.folder.name);
		if(![FolderDAO updateFolder:self.folder error:&error]) 
		{
			ALog ("Error occured while updating Folder");
		}
		else {
			ALog ("Folder updated");
		}
		TasksListViewController *folderView = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
		folderView.title = self.folder.name;
		
		[self.parent.controllersSection1 addObject:folderView];
		[self.parent.list addObject:self.folder];
		[folderView release];
		[order release];
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (IBAction) textFieldDone:(id)sender {
	[sender resignFirstResponder];
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
	
	if(self.folder != nil)
		self.nameTextField.text = self.folder.name;
	
	UIImageView *leftViewImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallWhiteBoarderedButton.png"]];
	//TODO: change color
	leftViewImage.backgroundColor = [UIColor redColor];
	self.nameTextField.leftView = leftViewImage;
	self.nameTextField.leftViewMode = UITextFieldViewModeAlways;
	[leftViewImage release];
	[self.nameTextField becomeFirstResponder];
	
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.nameTextField = nil;
	self.folder = nil;
	self.parent = nil;
}


- (void)dealloc {
	[_folder release];
	
    [super dealloc];
}

- (IBAction)colorButtonPressed:(id)sender {
	UIButton *button = (UIButton *)sender;
	self.color = button.backgroundColor;
	((UIImageView *)self.nameTextField.leftView).backgroundColor = self.color;
}


@end
