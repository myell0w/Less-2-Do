//
//  HomeFirstLevelViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 20.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "HomeFirstLevelViewController.h"
#import "HomeNavigationController.h"
#import "TasksListViewController.h"
#import "TDBadgedCell.h"
#import "Task.h"

#define TAG_COUNT 31


@implementation HomeFirstLevelViewController

@synthesize tableView;
@synthesize controllersSection0;
@synthesize controllersSection1;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(void)viewDidLoad {
	// array to hold the second-level controllers
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	// init Second-Level Views in Section Home
	TasksListViewController *all = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	all.title = @"All Tasks";
	all.image = [UIImage imageNamed:@"home_all.png"];
	[array addObject:all];
	[all release];
	
	// init Second-Level Views in Section Home
	TasksListViewController *starred = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	starred.title = @"Starred";
	starred.selector = @selector(getStarredTasks:);
	starred.image = [UIImage imageNamed:@"home_starred.png"];
	[array addObject:starred];
	[starred release];

	// init Second-Level Views in Section Home
	TasksListViewController *compl = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	compl.title = @"Completed";
	compl.selector = @selector(getCompletedTasks:);
	compl.image = [UIImage imageNamed:@"home_completed.png"];
	[array addObject:compl];
	[compl release];
	
	// first 3 controllers make up section0
	self.controllersSection0 = array;
	[array release];
	array = [[NSMutableArray alloc] init];

	// init Second-Level Views in Section Home
	TasksListViewController *overdue = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	overdue.title = @"Overdue";
	overdue.selector = @selector(getTasksOverdue:);
	overdue.image = [UIImage imageNamed:@"home_overdue.png"];
	[array addObject:overdue];
	[overdue release];

	// init Second-Level Views in Section Home
	TasksListViewController *today = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	today.title = @"Today";
	today.selector = @selector(getTasksToday:);
	today.image = [UIImage imageNamed:@"home_today.png"];
	[array addObject:today];
	[today release];

	// init Second-Level Views in Section Home
	TasksListViewController *week = [[TasksListViewController alloc] initWithStyle:UITableViewStylePlain];
	week.title = @"This Week";
	week.selector = @selector(getTasksThisWeek:);
	week.image = [UIImage imageNamed:@"home_this_week.png"];
	[array addObject:week];
	[week release];

	// others make up section1
	self.controllersSection1 = array;
	self.title = @"Home";
	
	// register as observer for Notification sent by QuickAddViewController and EditTaskViewController
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(taskAdded) 
												 name:@"TaskAddedNotification" object:nil];
	
	[array release];
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
}

-(void)viewDidUnload {
	self.tableView = nil;
	self.controllersSection0 = nil;
	self.controllersSection1 = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super viewDidUnload];
}

-(void)dealloc {
	[self.tableView release];
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
	static NSString *cellID = @"HomeSecondLevelCellID";
	
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	TDBadgedCell *cell = (TDBadgedCell *)[self.tableView dequeueReusableCellWithIdentifier:cellID];
	
	if (cell == nil) {
		cell = [[[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	// customize cell-appearance:
	TasksListViewController *c = [[self sectionForIndex:section] objectAtIndex:row];
	
	cell.textLabel.text = c.title; 
	cell.badgeNumber = c.taskCount;
  cell.imageView.image = c.image;
	
	return cell;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Table View Delegate Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	HomeNavigationController *nc = (HomeNavigationController *)self.navigationController;
	
	[nc hideQuickAdd];
	
	// Show a List of Tasks
	TasksListViewController *next = [[self sectionForIndex:section] objectAtIndex:row];
	
	[nc pushViewController:next animated:YES];
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

- (IBAction)taskAdded {
	[self.tableView reloadData];
}

@end
