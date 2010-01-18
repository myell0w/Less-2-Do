//
//  TaskEditFolderViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 06.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "TaskEditFolderViewController.h"
#import "Folder.h"


#define FONT_SIZE 15


@implementation TaskEditFolderViewController

@synthesize task;
@synthesize tableView;
@synthesize addFolderControl;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSError *error;
	NSArray *objects = [Folder getAllFolders:&error];
	
    folders = [[NSMutableArray alloc] init];
	[folders addObjectsFromArray:objects];	
	
	ALog("Folders read: %@", folders);
}



- (void)viewWillAppear:(BOOL)animated {
	// pre-check row if task has folder set
	if (self.task.folder != nil) {
		NSUInteger idx = [folders indexOfObject:self.task.folder];
		lastIndexPath = [NSIndexPath indexPathForRow:idx inSection:1];
	} else {
		lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
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
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return 1;
	
    return [folders count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"FolderCellInTaskEdit";
	static NSString *cellIDNoFolder = @"FolderCellInTaskEditNoFolder";
	
	Folder *folder = nil;
	UITableViewCell *cell = nil;
    
	if (indexPath.section == 0) {
		cell = [aTableView dequeueReusableCellWithIdentifier:cellIDNoFolder];
	} else {
		cell = [aTableView dequeueReusableCellWithIdentifier:cellID];
		folder = [folders objectAtIndex:indexPath.row];
	}

    // create new cell
	if (cell == nil) {
		if (indexPath.section == 0) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDNoFolder] autorelease];
		} else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
			
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12,12,22,22)];
			imageView.image = [UIImage imageNamed:@"smallWhiteBoarderedButton.png"];
			imageView.tag = TAG_COLOR;
			[cell.contentView addSubview:imageView];
			[imageView release];
			
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(46,10,235,27)];
			label.tag = TAG_FOLDER;
			label.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
			[cell.contentView addSubview:label];
			[label release];
		}
    }
	
	// Set up the cell...
	if (indexPath.section == 0) {
		cell.textLabel.text = @"No Folder";
		cell.imageView.image = [UIImage imageNamed:@"no_folder.png"];
		cell.accessoryType = [indexPath isEqual:lastIndexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	} else {
		UIView *colorView = [cell.contentView viewWithTag:TAG_COLOR];
		colorView.backgroundColor = [folder color];
		
		UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:TAG_FOLDER];
		textLabel.text = folder.name;
		cell.accessoryType = [indexPath isEqual:lastIndexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		[addFolderControl resignFirstResponder];
		
		if (![indexPath isEqual:lastIndexPath]) {
			UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
			newCell.accessoryType = UITableViewCellAccessoryCheckmark;
			
			UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath]; 
			oldCell.accessoryType = UITableViewCellAccessoryNone;
			
			lastIndexPath = indexPath;
			self.task.folder = nil;
		}
		
	} else {
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
	folder.r = [NSNumber numberWithDouble:1.0];
	folder.g = [NSNumber numberWithDouble:1.0];
	folder.b = [NSNumber numberWithDouble:1.0];
	[order release];
	
	ALog ("Folder %@ inserted", folder);
	
	[folders addObject:folder];
	self.task.folder = folder;
	
	NSUInteger idx = [folders indexOfObject:folder];
	lastIndexPath = [NSIndexPath indexPathForRow:idx inSection:1];
	
	self.addFolderControl.text = @"";
	[self.tableView reloadData];
}

@end
