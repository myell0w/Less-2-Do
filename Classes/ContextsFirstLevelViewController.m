//
//  ContextsFirstLevelViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 20.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "ContextsFirstLevelViewController.h"
#import "TasksListViewController.h"

@implementation ContextsFirstLevelViewController

@synthesize tableView;
@synthesize controllersSection0;
@synthesize controllersSection1;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)viewDidLoad {
	// array to hold the second-level controllers
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	// init Second-Level Views in Section Contexts
	TasksListViewController *no = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	no.title = @"No Context";
	no.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:no];
	[no release];
	
	
	self.controllersSection0 = array;
	[array release];
	array = [[NSMutableArray alloc] init];
	
	// init Second-Level Views in Section Home
	TasksListViewController *context1 = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	context1.title = @"home";
	context1.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:context1];
	[context1 release];
	
	[ContextDAO addContextWithName:@"Johannes' Wohnung"];
	ALog(@"%s", "Keine Wohnungen mehr");
	// init Second-Level Views in Section Home
	/*TasksListViewController *context2 = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	context2.title = @"telephone";
	context2.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:context2];
	[context2 release];*/
	
	/* ------------ KEINE AHNUNG -------------- */
	
	/* zuerst eines anlegen */
	/*NSError *saveError;
	Context *newContext = [[Context alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
	newContext.name = @"bussi";
	[moc save:&saveError];*/
	/* ende anlegen */
	
	//ContextDAO *contextDAO = [[ContextDAO alloc] init];
	NSArray *objects = [ContextDAO allContexts];
	
	if (objects == nil) {
		NSLog(@"There was an error!");
		// Do whatever error handling is appropriate
	}
	if ([objects count] > 0)
	{
		// for schleife objekte erzeugen und array addObject:currentContext
		for (int i=0; i<[objects count]; i++) {
			Context *context = [objects objectAtIndex:i];
			TasksListViewController *context2 = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
			context2.title = context.name;
			context2.image = [UIImage imageNamed:@"all_tasks.png"];
			[array addObject:context2];
			[context2 release];
		}
	}
	
	
	/* -------------- ENDE KEINE AHNUNG ------------- */
	
	self.controllersSection1 = array;
		
	self.title = @"Contexts";
	
	[array release];
	[super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.tableView = nil;
	self.controllersSection0 = nil;
	self.controllersSection1 = nil;
}


- (void)dealloc {
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
	return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[self sectionForIndex:section] count];
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"ContextsSecondLevelCellID";
	
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
