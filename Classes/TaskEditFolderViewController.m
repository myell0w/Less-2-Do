//
//  TaskEditFolderViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 06.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "TaskEditFolderViewController.h"
#import "FolderDAO.h"
#import "FolderCell.h"

#define TAG_COLOR  1
#define TAG_FOLDER 2

#define NORMAL_FONT_SIZE 15


@implementation TaskEditFolderViewController

@synthesize task;
@synthesize tableView;
@synthesize addFolderControl;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSError *error;
	NSArray *objects = [FolderDAO allFolders:&error];
	
    folders = [[NSMutableArray alloc] init];
	[folders addObjectsFromArray:objects];	
	
	ALog("Folders read: %@", folders);
}



- (void)viewWillAppear:(BOOL)animated {
	// pre-check row if task has folder set
	if (self.task.folder != nil) {
		NSUInteger idx = [folders indexOfObject:self.task.folder];
		lastIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
	}
	
    [super viewWillAppear:animated];
}

/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.tableView = nil;
	self.addFolderControl = nil;
	self.task = nil;
	
	[folders release];
	folders = nil;
	
	[lastIndexPath release];
	lastIndexPath = nil;
}

- (void)dealloc {
	[tableView release];
	[task release];
	[addFolderControl release];
	[folders release];
	[lastIndexPath release];
	
    [super dealloc];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [folders count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"FolderCellInTaskEdit";
	int row = [indexPath row];
	Folder *folder = [folders objectAtIndex:row];
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellID];
    // create new cell
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
		
		UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(12,12,22,22)];
		colorView.tag = TAG_COLOR;
		[cell.contentView addSubview:colorView];
		[colorView release];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(46,10,235,27)];
		label.tag = TAG_FOLDER;
		label.font = [UIFont boldSystemFontOfSize:NORMAL_FONT_SIZE];
		[cell.contentView addSubview:label];
		[label release];
    }
	
	// Set up the cell...
	UIView *colorView = [cell.contentView viewWithTag:TAG_COLOR];
	colorView.backgroundColor = [folder color];
	
	UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:TAG_FOLDER];
	textLabel.text = [folder description];
	cell.accessoryType = [indexPath isEqual:lastIndexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
    return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	Folder *f = (Folder *)[folders objectAtIndex:row];
    
    ALog("Selected Folder: %@", f);
	[addFolderControl resignFirstResponder];
	
    if (![indexPath isEqual:lastIndexPath]) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath]; 
        oldCell.accessoryType = UITableViewCellAccessoryNone;
		
        lastIndexPath = indexPath;
		self.task.folder = f;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)addFolder:(id)sender {
	[addFolderControl resignFirstResponder];
	
	// Only Saves when text was entered
	if (addFolderControl.text.length == 0)
		return;
	
	NSNumber *order = [[NSNumber alloc] initWithInt:[folders count]];
	Folder *folder = (Folder *)[Folder objectOfType:@"Folder"];
	folder.name = addFolderControl.text;
	folder.order = order;
	[order release];
	
	ALog ("Folder %@ inserted", folder);
	
	[folders addObject:folder];
	self.task.folder = folder;
	
	NSUInteger idx = [folders indexOfObject:folder];
	lastIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
	
	self.addFolderControl.text = @"";
	[self.tableView reloadData];
}

@end
