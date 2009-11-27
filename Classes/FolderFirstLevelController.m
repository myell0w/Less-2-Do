//
//  FolderFirstLevelController.m
//  Less2Do
//
//  Created by Philip Messlehner on 23.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FolderFirstLevelController.h"
#import "TasksListViewController.h"

@implementation FolderFirstLevelController
@synthesize tableView;
@synthesize controllersSection0;
@synthesize controllersSection1;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)viewDidLoad {
	// array to hold the second-level controllers
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
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
	
	// TODO Load Folder
	
	// init Second-Level Views in Section Folder
	TasksListViewController *folder1 = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	folder1.title = @"Folder1";
	folder1.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:folder1];
	[folder1 release];
	
	// init Second-Level Views in Section Folder
	TasksListViewController *folder2 = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	folder2.title = @"Folder2";
	folder2.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:folder2];
	[folder2 release];
	
	// init Second-Level Views in Section Folder
	TasksListViewController *folder3 = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	folder3.title = @"Folder3";
	folder3.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:folder3];
	[folder3 release];
	
	// folder make up section1
	self.controllersSection1 = array;
	[array release];
	self.title = @"Folder";
	[super viewDidLoad];
}

-(void)viewDidUnload {
	self.tableView = nil;
	self.controllersSection0 = nil;
	self.controllersSection1 = nil;
	
	[super viewDidUnload];
}

-(void)dealloc {
	[tableView release];
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
	if ([controllersSection1 count] == 0)
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
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	NSString *detail = [[NSString alloc]initWithFormat:@"[%d Tasks]",c.taskCount];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
	}
	
	cell.textLabel.text = c.title;
	cell.detailTextLabel.text = detail;
	cell.imageView.image = c.image;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	[detail release];
	
	return cell;
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
