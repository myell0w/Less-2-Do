//
//  TagsFirstLevelController.m
//  Less2Do
//
//  Created by Philip Messlehner on 23.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TagsFirstLevelController.h"
#import "EditTagViewController.h"
#import "TasksListViewController.h"
#import "TDBadgedCell.h"
#import "Tag.h"

@implementation TagsFirstLevelController
@synthesize list;
@synthesize controllersSection0;
@synthesize controllersSection1;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
	self.title = @"Tags";
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	// array to hold the second-level controllers
	NSMutableArray *array = [[NSMutableArray alloc] init];
	list = [[NSMutableArray alloc] init];
	
	//init Second-Level Views in Section Tags
	
	//View for untagged Tasks
	TasksListViewController *untagged = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	untagged.title = @"Untagged";
	untagged.image = [UIImage imageNamed:@"no_tags.png"];
	untagged.selector = @selector(getTasksWithoutTag:);
	[array addObject:untagged];
	[untagged release];
	
	// put Untagged-Controller in Section #0
	self.controllersSection0 = array;
	[array release];
	array = [[NSMutableArray alloc] init];
	
	// TODO: Load Tasks
	NSError *error;
	NSArray *objects = [Tag getAllTags:&error];
	
	if (objects == nil) {
		ALog(@"Error while reading Contexts!");
	}
	if ([objects count] > 0)
	{
		// for schleife objekte erzeugen und array addObject:currentContext
		for (int i=0; i<[objects count]; i++) {
			Tag *tag = [objects objectAtIndex:i];
			//if(tag.tasks != nil)
				//ALog("%@ %@", tag.name, [tag.tasks count]);
			
			TasksListViewController *tagView = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
			tagView.title = tag.name;
			tagView.image = [UIImage imageNamed:@"tag.png"];
			tagView.selector = @selector(getTasksWithTag:error:);
			tagView.argument = [objects objectAtIndex:i];
			[array addObject:tagView];
			[tagView release];
		}
	}
	
	[list addObjectsFromArray:objects];
	DLog ("%d Items in TagList", [list count]);
	
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
	// if there is no Tag, only display the first Section
	if ([list count] == 0)
		return 1;
	return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[self sectionForIndex:section] count];
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"TagsSecondLevelCellID";
	
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	TasksListViewController *c = [[self sectionForIndex:section] objectAtIndex:row];
	TDBadgedCell *cell = (TDBadgedCell *)[self.tableView dequeueReusableCellWithIdentifier:cellID];
	
	if (cell == nil) {
		cell = [[[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
	}
	
	cell.badgeNumber = c.taskCount;
	cell.imageView.image = c.image;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if(section==0) {
		cell.textLabel.text = c.title;
		cell.editingAccessoryType = UITableViewCellAccessoryNone;
	}
	else {
		Tag *tag = [list objectAtIndex:row];
		cell.textLabel.text = tag.name;
		cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSUInteger row = [indexPath row];	
		NSError *error;
		Tag *tag = [list objectAtIndex:row];
		
		NSMutableArray *tasksToRemove = [NSMutableArray array];
		for(Task *t in tag.tasks)
		{
			[tasksToRemove addObject:t];
		}
		for(Task *t in tasksToRemove)
		{
			[t removeTagsObject:tag];
		}
		[tag removeTasks:[NSSet setWithArray:tasksToRemove]];
		
		DLog ("Try to delete Tag '%@'", tag.name);
		[self.controllersSection1 removeObjectAtIndex:row];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
							  withRowAnimation:UITableViewRowAnimationFade];
		DLog ("Removed Tag '%@' from SectionController", tag.name);
		if(![BaseManagedObject deleteObjectFromPersistentStore:tag error:&error]) {
			ALog("Error occured while deleting Tag");
		}
		else
			ALog("Deleted Tag");
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
		DLog ("%d Items in TagList", [list count]);
		Tag *tag = [list objectAtIndex:row];
		DLog ("Try to load DetailView for Tag '%@'", tag.name);
		
		[self.tableView setEditing:NO animated:NO];
		[self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
		[self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleBordered];
		
		EditTagViewController *tagDetail = [[EditTagViewController alloc] initWithNibName:@"EditTagViewController" bundle:nil parent:self tag:tag];
		tagDetail.title = tag.name;
		[self.navigationController pushViewController:tagDetail animated:YES];
		[tagDetail release];
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
	}
}

- (IBAction)toggleAdd:(id)sender {
	EditTagViewController *tagDetail = [[EditTagViewController alloc] initWithNibName:@"EditTagViewController" bundle:nil parent:self];
	tagDetail.title = @"New Tag";
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:tagDetail];
	[tagDetail release];
	[self presentModalViewController:nc animated:YES];
	[nc release];
}

@end
