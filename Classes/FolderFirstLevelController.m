//
//  FolderFirstLevelController.m
//  Less2Do
//
//  Created by Philip Messlehner on 23.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FolderFirstLevelController.h"
#import "TasksListViewController.h"
#import "FolderDAO.h"
#import "FolderDetailViewController.h"

@implementation FolderFirstLevelController
@synthesize list;
@synthesize controllersSection0;
@synthesize controllersSection1;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(IBAction)toggleEdit:(id)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if (self.tableView.editing) {
        [self.navigationItem.leftBarButtonItem setTitle:@"Done"];
		[self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleDone];
	}
    else {
        [self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
		[self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleBordered];
	}
}

- (IBAction)toggleAdd:(id)sender {
	FolderDetailViewController *folderDetail = [[FolderDetailViewController alloc] initWithStyle:UITableViewStyleGrouped andParent:self];
	folderDetail.title = @"New Folder";
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:folderDetail];
	[folderDetail release];
	[self presentModalViewController:nc animated:YES];
	[nc release];
}

- (void)viewDidLoad {
	ALog ("FolderDetailView start DidLoad");
	// array to hold the second-level controllers
	NSMutableArray *array = [[NSMutableArray alloc] init];
	list = [[NSMutableArray alloc] init];
	
	//init Second-Level Views in Section Tags
	
	//View for No Folder Tasks
	TasksListViewController *nofolder = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	nofolder.title = @"No Folder";
	nofolder.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:nofolder];
	[nofolder release];
	
	// put No_Folder-Controller and Any_Folder-Controller in Section #0
	self.controllersSection0 = array;
	[array release];
	array = [[NSMutableArray alloc] init];
	
	// TODO: Load Folder
	NSError *error;
	NSArray *objects = [FolderDAO allFolders:&error];
	
	if (objects == nil) {
		ALog(@"Error while reading Folders!");
	}
	
	if ([objects count] > 0)
	{
		// for schleife objekte erzeugen und array addObject:currentContext
		for (int i=0; i<[objects count]; i++) {
			Context *folder = [[objects objectAtIndex:i] retain];
			TasksListViewController *folderView = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
			folderView.title = folder.name;
			folderView.image = [UIImage imageNamed:@"all_tasks.png"];
			[array addObject:folderView];
			[folderView release];
		}
	}
	
	[list addObjectsFromArray:objects];
	DLog ("%d Items in FolderList", [list count]);
	
	self.controllersSection1 = array;
	self.title = @"Folder";
	[array release];
	
	UIView *textField = [self.tableView viewWithTag:NAME_ROW_INDEX];
	if(textField != nil) {
		ALog ("Textfield found");
		[textField resignFirstResponder];
	}
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
}

-(void)viewDidUnload {
	self.list = nil;
	self.controllersSection0 = nil;
	self.controllersSection1 = nil;
	
	[super viewDidUnload];
}

-(void)dealloc {
	[list release];
	[controllersSection0 release];
	[controllersSection1 release];
	
	[super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Table Data Source Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// if there is no Folder, only display the first Section
	if ([list count] == 0)
		return 1;
	return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[self sectionForIndex:section] count];
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"FolderSecondLevelCellID";
	
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	TasksListViewController *c = [[self sectionForIndex:section] objectAtIndex:row];
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
	NSString *detail = [[NSString alloc]initWithFormat:@"[%d Tasks]",c.taskCount];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
	}
	
	cell.detailTextLabel.text = detail;
	cell.imageView.image = c.image;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	
	if(section==0) {
		cell.textLabel.text = c.title;
		cell.editingAccessoryType = UITableViewCellAccessoryNone;
	}
	else {
		Folder *folder = [list objectAtIndex:row];
		cell.textLabel.text = folder.name;
		cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	
	[detail release];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSUInteger row = [indexPath row];	
		NSError *error;
		Folder *folder = [list objectAtIndex:row];
		DLog ("Try to delete Folder '%@'", folder.name);
		[self.controllersSection1 removeObjectAtIndex:row];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
							  withRowAnimation:UITableViewRowAnimationFade];
		DLog ("Removed Folder '%@' from FolderController", folder.name);
		if(![FolderDAO deleteFolder:folder error:&error]) {
			ALog("Error occured while deleting Folder");
		}
		else
			ALog("Deleted Folder");
		[self.list removeObjectAtIndex:row];
		[tableView reloadData];
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Table View Delegate Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	
	TasksListViewController *next = [[self sectionForIndex:section] objectAtIndex:row];
	
	[self.navigationController pushViewController:next animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	if([indexPath section] == 1) {
		NSUInteger row = [indexPath row];
		DLog ("%d Items in FolderList", [list count]);
		Folder *folder = [list objectAtIndex:row];
		DLog ("Try to load DetailView for Folder '%@'", folder.name);
		
		[self.tableView setEditing:NO animated:NO];
		[self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
		[self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleBordered];
		
		FolderDetailViewController *folderDetail = [[FolderDetailViewController alloc] initWithStyle:UITableViewStyleGrouped andParent:self andFolder:folder];
		folderDetail.title = folder.name;
		[self.navigationController pushViewController:folderDetail animated:YES];
		[folderDetail release];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0)
		return UITableViewCellEditingStyleNone;
	return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0)
		return NO;
	return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if([indexPath section] == 0)
		return NO;
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSNumber *fromRow = [[NSNumber alloc] initWithInt:[fromIndexPath row]];
    NSNumber *toRow = [[NSNumber alloc] initWithInt:[toIndexPath row]];
    
	Folder *fromObject = [self.list objectAtIndex:[fromIndexPath row]];
	fromObject.order = toRow;
	Folder *toObject = [self.list objectAtIndex:[toIndexPath row]];
	fromObject.order = fromRow;
	
	NSError *error;
	DLog ("Try to update Folders (ordering)");
	if(![FolderDAO updateFolder:fromObject error:&error] || ![FolderDAO updateFolder:toObject error:&error] ) {
		ALog ("Error occured while updating Folder (ordering)");
	}
	else {
		ALog ("Folder updated (ordering)");
		ALog ("Folder: %@, Order: %d", toObject.name, toObject.order);
		ALog ("Folder: %@, Order: %d", fromObject.name, fromObject.order);
	}
	
	[fromRow release];
	[toRow release];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Custom Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// returns either controllersSection0 or 1, depending on the section-index
-(NSArray *) sectionForIndex:(NSInteger)index {
	if (index == 0) {
		return controllersSection0;
	} else {
		return controllersSection1;
	}
}

@end
