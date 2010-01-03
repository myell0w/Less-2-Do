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
#import "EditFolderViewController.h"
#import "FolderCell.h"

@implementation FolderFirstLevelController
@synthesize list = _list;
@synthesize controllersSection0 = _controllersSection0;
@synthesize controllersSection1 = _controllersSection1;
@synthesize mustReorder = _mustReorder;

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
		DLog ("Go to reorder");
		if (self.mustReorder == YES) 
			[self reorderList];
	}
}

- (IBAction)toggleAdd:(id)sender {
	EditFolderViewController *folderDetail = [[EditFolderViewController alloc] initWithNibName:@"EditFolderViewController" bundle:nil parent:self];
	folderDetail.title = @"New Folder";
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:folderDetail];
	
	[self presentModalViewController:nc animated:YES];
	[folderDetail release];
	[nc release];
}

- (void)viewDidLoad {
	ALog ("FolderDetailView start DidLoad");
	// array to hold the second-level controllers
	NSMutableArray *array = [[NSMutableArray alloc] init];
	self.list = [[NSMutableArray alloc] init];
	
	//init Second-Level Views in Section Tags
	
	//View for No Folder Tasks
	TasksListViewController *nofolder = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	nofolder.title = @"No Folder";
	[array addObject:nofolder];
	[nofolder release];
	
	// put No_Folder-Controller and Any_Folder-Controller in Section #0
	self.controllersSection0 = array;
	[array release];
	array = [[NSMutableArray alloc] init];
	
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
			folderView.selector = @selector(getTasksInFolder:error:);
			folderView.argument = [objects objectAtIndex:i];
			[array addObject:folderView];
			[folderView release];
		}
	}
	
	[self.list addObjectsFromArray:objects];
	DLog ("%d Items in FolderList", [self.list count]);
	
	self.controllersSection1 = array;
	self.title = @"Folder";
	[array release];
	
	self.mustReorder = NO;
	
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
	[_list release];
	[_controllersSection0 release];
	[_controllersSection1 release];
	
	[super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Table Data Source Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// if there is no Folder, only display the first Section
	if ([self.list count] == 0)
		return 1;
	return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[self sectionForIndex:section] count];
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"FolderSecondLevelCellID";
	static NSString *folderCellID = @"FolderCellID";
	
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	TasksListViewController *c = [[self sectionForIndex:section] objectAtIndex:row];
	UITableViewCell *cell;
	if(section==0)
		cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
	else {
		cell = [self.tableView dequeueReusableCellWithIdentifier:folderCellID];
	}

	NSString *detail = [[NSString alloc]initWithFormat:@"[%d Tasks]",c.taskCount];
	
	if (cell == nil) {
		if(section==0)
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
		else {
			//NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FolderCell" owner:self options:nil];
			//for (id oneObject in nib) if ([oneObject isKindOfClass:[FolderCell class]])
				cell = (FolderCell *)[CustomCell loadFromNib:@"FolderCell" withOwner:self];
		}

	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	
	if(section==0) {
		cell.detailTextLabel.text = detail;
		cell.textLabel.text = c.title;
		cell.editingAccessoryType = UITableViewCellAccessoryNone;
	}
	else {
		Folder *folder = [self.list objectAtIndex:row];
		((FolderCell *)cell).title.text = folder.name;
		((FolderCell *)cell).detail.text = detail;
		((FolderCell *)cell).imageView.backgroundColor = [folder color]; 
		ALog ("%@: %@ %@ %@", folder.name, folder.r, folder.g, folder.b);
		cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	
	[detail release];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSUInteger row = [indexPath row];	
		NSError *error;
		Folder *folder = [self.list objectAtIndex:row];
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if([indexPath section] == 0)
		return NO;
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    self.mustReorder = YES;
	DLog ("moved Row");
	
	NSUInteger fromRow = [fromIndexPath row];
    NSUInteger toRow = [toIndexPath row];
    
    id object = [[self.list objectAtIndex:fromRow] retain];
    [self.list removeObjectAtIndex:fromRow];
    [self.list insertObject:object atIndex:toRow];
    [object release];
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
		Folder *folder = [self.list objectAtIndex:row];
		DLog ("Try to load DetailView for Folder '%@'", folder.name);
		
		[self.tableView setEditing:NO animated:NO];
		[self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
		[self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleBordered];
		
		EditFolderViewController *folderDetail = [[EditFolderViewController alloc] initWithNibName:@"EditFolderViewController" bundle:nil parent:self folder:folder];
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

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	if ([proposedDestinationIndexPath section] == 0)
		return sourceIndexPath;
	return proposedDestinationIndexPath;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Custom Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// returns either controllersSection0 or 1, depending on the section-index
-(NSArray *) sectionForIndex:(NSInteger)index {
	if (index == 0) {
		return self.controllersSection0;
	}
	return self.controllersSection1;
}

// reorders the List with act. Index in List
- (void)reorderList {
	for(int i=0; i<[self.list count]; i++) {
		Folder *folder=(Folder *)[self.list objectAtIndex:i];
		NSNumber *order = [[NSNumber alloc] initWithInt:i];
		folder.order = order;
		[order release];
		NSError *error;
		DLog ("Try to update Folders (ordering): %@, order %@", folder.name, folder.order);
		if(![FolderDAO updateFolder:folder error:&error]) {
			ALog ("Error occured while updating Folder (ordering)");
		}
	}
	self.mustReorder = NO;
}

@end
