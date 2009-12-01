//
//  TagsFirstLevelController.m
//  Less2Do
//
//  Created by Philip Messlehner on 23.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TagsFirstLevelController.h"
#import "TagDetailController.h"
#import "TasksListViewController.h"
#import "TagDAO.h"

@implementation TagsFirstLevelController
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
	TagDetailController *tagDetail = [[TagDetailController alloc] initWithStyle:UITableViewStyleGrouped];
	tagDetail.title = @"New Tag";
	[self.navigationController pushViewController:tagDetail animated:YES];
	[tagDetail release];
}

- (void)viewDidLoad {
	// array to hold the second-level controllers
	NSMutableArray *array = [[NSMutableArray alloc] init];
	list = [[NSMutableArray alloc] init];
	
	//init Second-Level Views in Section Tags
	
	//View for untagged Tasks
	TasksListViewController *untagged = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	untagged.title = @"Untagged";
	untagged.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:untagged];
	[untagged release];
	
	// put Untagged-Controller in Section #0
	self.controllersSection0 = array;
	[array release];
	array = [[NSMutableArray alloc] init];
	
	// TODO: Load Tasks
	NSError *error;
	NSArray *objects = [TagDAO allTags:&error];
	
	if (objects == nil) {
		ALog(@"Error while reading Contexts!");
	}
	if ([objects count] > 0)
	{
		// for schleife objekte erzeugen und array addObject:currentContext
		for (int i=0; i<[objects count]; i++) {
			Tag *tag = [[objects objectAtIndex:i] retain];
			TasksListViewController *tagView = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
			tagView.title = tag.name;
			tagView.image = [UIImage imageNamed:@"all_tasks.png"];
			[array addObject:tagView];
			[tagView release];
		}
	}
	
	[list addObjectsFromArray:objects];
	DLog ("%d Items in TagList", [list count]);
	
	self.controllersSection1 = array;
	self.title = @"Tags";
	[array release];
	[super viewDidLoad]; 
	
	/* init Second-Level Views in Section Tags
	TasksListViewController *tag1 = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	tag1.title = @"@Tag1";
	tag1.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:tag1];
	[tag1 release];
	
	// init Second-Level Views in Section Tags
	TasksListViewController *tag2 = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	tag2.title = @"@Tag2";
	tag2.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:tag2];
	[tag2 release];
	
	// init Second-Level Views in Section Tags
	TasksListViewController *tag3 = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	tag3.title = @"@Tag3";
	tag3.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:tag3];
	[tag3 release];
	
	// tags make up section1
	self.controllersSection1 = array;
	[array release];
	self.title = @"Tags";
	[super viewDidLoad];*/
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
		Tag *tag = [list objectAtIndex:row];
		cell.textLabel.text = tag.name;
		cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	
	[detail release];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSUInteger row = [indexPath row];	
		NSError *error;
		Tag *tag = [list objectAtIndex:row];
		DLog ("Try to delete Tag '%@'", tag.name);
		[self.controllersSection1 removeObjectAtIndex:row];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
							  withRowAnimation:UITableViewRowAnimationFade];
		DLog ("Removed Tag '%@' from SectionController", tag.name);
		if(![TagDAO deleteTag:tag error:&error]) {
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
		
		TagDetailController *tagDetail = [[TagDetailController alloc] initWithStyle:UITableViewStyleGrouped andTag:tag];
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

@end
