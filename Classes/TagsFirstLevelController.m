//
//  TagsFirstLevelController.m
//  Less2Do
//
//  Created by Philip Messlehner on 23.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TagsFirstLevelController.h"
#import "TasksListViewController.h"


@implementation TagsFirstLevelController
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
	
	//View for untagged Tasks
	TasksListViewController *untagged = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	untagged.title = @"Untagged";
	[array addObject:untagged];
	[untagged release];
	
	// put Untagged-Controller in Section #0
	self.controllersSection0 = array;
	[array release];
	array = [[NSMutableArray alloc] init];
	
	// TODO Load Tasks
	
	// init Second-Level Views in Section Tags
	TasksListViewController *tag1 = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	tag1.title = @"@Tag1";
	[array addObject:tag1];
	[tag1 release];
	
	// init Second-Level Views in Section Tags
	TasksListViewController *tag2 = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	tag2.title = @"@Tag2";
	[array addObject:tag2];
	[tag2 release];
	
	// init Second-Level Views in Section Tags
	TasksListViewController *tag3 = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	tag3.title = @"@Tag3";
	[array addObject:tag3];
	[tag3 release];
	
	// tags make up section1
	self.controllersSection1 = array;
	[array release];
	self.title = @"Tags";
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
	// if there is no Tag, only display the first Section
	if ([controllersSection1 count] == 0)
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
