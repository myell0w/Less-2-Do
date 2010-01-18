//
//  FolderFirstLevelController.m
//  Less2Do
//
//  Created by Philip Messlehner on 23.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FolderFirstLevelController.h"
#import "TasksListViewController.h"
#import "Folder.h"
#import "TDBadgedCell.h"
#import "EditFolderViewController.h"
#import "Includes.h"

#define FONT_SIZE 18

@implementation FolderFirstLevelController
@synthesize list = _list;
@synthesize controllersSection0 = _controllersSection0;
@synthesize controllersSection1 = _controllersSection1;
@synthesize mustReorder = _mustReorder;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
	ALog ("FolderDetailView start DidLoad");
	self.title = @"Folder";
	self.mustReorder = NO;
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	// array to hold the second-level controllers
	NSMutableArray *array = [[NSMutableArray alloc] init];
	self.list = [[NSMutableArray alloc] init];
	
	//init Second-Level Views in Section Tags
	
	//View for No Folder Tasks
	TasksListViewController *nofolder = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	nofolder.title = @"No Folder";
	nofolder.image = [UIImage imageNamed:@"no_folder.png"];
	nofolder.selector = @selector(getTasksWithoutFolder:);
	[array addObject:nofolder];
	[nofolder release];
	
	// put No_Folder-Controller and Any_Folder-Controller in Section #0
	self.controllersSection0 = array;
	[array release];
	array = [[NSMutableArray alloc] init];
	
	NSError *error;
	NSArray *objects = [Folder getAllFolders:&error];
	
	if (objects == nil) {
		ALog(@"Error while reading Folders!");
	}
	
	if ([objects count] > 0)
	{
		// for schleife objekte erzeugen und array addObject:currentContext
		for (int i=0; i<[objects count]; i++) {
			Folder *folder = [objects objectAtIndex:i];
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
	[array release];
	
	[self.tableView reloadData];
	[super viewWillAppear:animated];
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
	TDBadgedCell *cell;
	
	if(section==0) {
		cell = (TDBadgedCell *)[self.tableView dequeueReusableCellWithIdentifier:cellID];
	} else {
		cell = (TDBadgedCell *)[self.tableView dequeueReusableCellWithIdentifier:folderCellID];
	}

	if (cell == nil) {
		if(section==0)
			cell = [[[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
		else {
			cell = [[[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:folderCellID] autorelease];
			
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12,12,22,22)];
			imageView.image = [UIImage imageNamed:@"smallWhiteBoarderedButton.png"];
			imageView.tag = TAG_COLOR;
			[cell.contentView addSubview:imageView];
			[imageView release];
			
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(46,10,190,27)];
			label.tag = TAG_FOLDER;
			label.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
			[cell.contentView addSubview:label];
			[label release];
		}

	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.badgeNumber = c.taskCount;
	
	if(section==0) {
		cell.textLabel.text = c.title;
		cell.imageView.image = c.image;
		cell.editingAccessoryType = UITableViewCellAccessoryNone;
	}
	else {
		Folder *folder = [self.list objectAtIndex:row];
		
		UIImageView *colorView = (UIImageView *)[cell.contentView viewWithTag:TAG_COLOR];
		colorView.backgroundColor = [folder color];
		
		UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:TAG_FOLDER];
		textLabel.text = folder.name;
		
		cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	
	
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSUInteger row = [indexPath row];	
		NSError *error;
		Folder *folder = [self.list objectAtIndex:row];
		
		for (Task *t in folder.tasks) {
			t.folder = nil;
		}
		
		[folder removeTasks:folder.tasks];
		
		DLog ("Try to delete Folder '%@'", folder.name);
		[self.controllersSection1 removeObjectAtIndex:row];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
							  withRowAnimation:UITableViewRowAnimationFade];
		DLog ("Removed Folder '%@' from FolderController", folder.name);
		if(![BaseManagedObject deleteObject:folder error:&error]) {
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
		DLog ("Try to update Folders (ordering): %@, order %@", folder.name, folder.order);
	}
	self.mustReorder = NO;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Action-Methods
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


@end
