//
//  ContextsFirstLevelViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 20.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "ContextsFirstLevelViewController.h"
#import "TasksListViewController.h"
#import "EditContextViewController.h"

@implementation ContextsFirstLevelViewController

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
	EditContextViewController *contextDetail = [[EditContextViewController alloc] initWithNibName:@"EditContextViewController" bundle:nil parent:self];
	contextDetail.title = @"Add Context";
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:contextDetail];
	[contextDetail release];
	[self presentModalViewController:nc animated:YES];
	[nc release];
}

-(void)viewDidLoad {
	// array to hold the second-level controllers
	NSMutableArray *array = [[NSMutableArray alloc] init];
	list = [[NSMutableArray alloc] init];
	
	// init Second-Level Views in Section Contexts
	TasksListViewController *no = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	no.title = @"No Context";
	no.image = [UIImage imageNamed:@"no_context.png"];
	no.selector = @selector(getTasksWithoutContext:);
	[array addObject:no];
	[no release];
	
	
	self.controllersSection0 = array;
	[array release];
	array = [[NSMutableArray alloc] init];
	
	NSError *error;
	NSArray *objects = [ContextDAO allContexts:&error];
	
	if (objects == nil) {
		ALog(@"Error while reading Contexts!");
	}
	if ([objects count] > 0)
	{
		// for schleife objekte erzeugen und array addObject:currentContext
		for (int i=0; i<[objects count]; i++) {
			Context *context = [[objects objectAtIndex:i] retain];
			TasksListViewController *contextView = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
			contextView.title = context.name;
			contextView.image = [context hasGps] ? [UIImage imageNamed:@"context_gps.png"] : [UIImage imageNamed:@"context_no_gps.png"];
			contextView.selector = @selector(getTasksInContext:error:);
			contextView.argument = [objects objectAtIndex:i];
			[array addObject:contextView];
			[contextView release];
		}
	}

	[list addObjectsFromArray:objects];
	DLog ("%d Items in ContextList", [list count]);
	
	self.controllersSection1 = array;
	self.title = @"Contexts";
	[array release];
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
	[super viewWillAppear:animated];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.list = nil;
	self.controllersSection0 = nil;
	self.controllersSection1 = nil;
}


- (void)dealloc {
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
	if([list count] == 0)
		return 1;
	return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[self sectionForIndex:section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"ContextsSecondLevelCellID";
	
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	TasksListViewController *c = [[self sectionForIndex:section] objectAtIndex:row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
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
		Context *context = [list objectAtIndex:row];
		cell.textLabel.text = context.name;
		cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}

	
	[detail release];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSUInteger row = [indexPath row];	
		NSError *error;
		Context *context = [list objectAtIndex:row];
		DLog ("Try to delete Context '%@'", context.name);
		[self.controllersSection1 removeObjectAtIndex:row];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
							  withRowAnimation:UITableViewRowAnimationFade];
		DLog ("Removed Context '%@' from SectionController", context.name);
		if(![ContextDAO deleteContext:context error:&error]) {
			ALog("Error occured while deleting Context");
		}
		else
			ALog("Deleted Context");
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
		ALog ("%d Items in ContextList", [list count]);
		Context *context = [list objectAtIndex:row];
		//ALog ("Try to load DetailView for Context '%@'", context.name);
		
		[self.tableView setEditing:NO animated:NO];
		[self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
		[self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleBordered];
		
		EditContextViewController *contextDetail = [[EditContextViewController alloc] initWithNibName:@"EditContextViewController" bundle:nil parent:self context:context];
		contextDetail.title = context.name;
		[self.navigationController pushViewController:contextDetail animated:YES];
		[contextDetail release];
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
