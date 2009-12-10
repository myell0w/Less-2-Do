//
//  SettingsFirstLevelController.m
//  Less2Do
//
//  Created by Philip Messlehner on 23.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SettingsFirstLevelController.h"
#import "SettingsViewController.h"

@implementation SettingsFirstLevelController

@synthesize controllersSection0 = _controllersSection0;
@synthesize controllersSection1 = _controllersSection1;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Lifecycle
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)viewDidLoad {
	// array to hold the second-level controllers
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	//init Second-Level Views in Section Tags
	
	//View for Sync
	SettingsViewController *sync = [[SettingsViewController alloc] initWithStyle:UITableViewStylePlain];
	sync.title = @"Sync";
	sync.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:sync];
	[sync release];
	
	//View for Reminder
	SettingsViewController *reminder = [[SettingsViewController alloc] initWithStyle:UITableViewStylePlain];
	reminder.title = @"Reminder";
	reminder.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:reminder];
	[reminder release];
	
	//View for Watchlist
	SettingsViewController *watchList = [[SettingsViewController alloc] initWithStyle:UITableViewStylePlain];
	watchList.title = @"Watchlist";
	watchList.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:watchList];
	[watchList release];
	
	// put the 1st three Settings in Section #0
	self.controllersSection0 = array;
	[array release];
	array = [[NSMutableArray alloc] init];
	
	// View for Used Fileds
	SettingsViewController *usedFields = [[SettingsViewController alloc] initWithStyle:UITableViewStylePlain];
	usedFields.title = @"Used Fields";
	usedFields.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:usedFields];
	[usedFields release];
	
	// View used for Purge Data
	SettingsViewController *purge = [[SettingsViewController alloc] initWithStyle:UITableViewStylePlain];
	purge.title = @"Purge Data";
	purge.image = [UIImage imageNamed:@"all_tasks.png"];
	[array addObject:purge];
	[purge release];
	
	// tags make up section1
	self.controllersSection1 = array;
	[array release];
	self.title = @"Settings";
	[super viewDidLoad];
}

-(void)viewDidUnload {
	self.tableView = nil;
	self.controllersSection0 = nil;
	self.controllersSection1 = nil;
	
	[super viewDidUnload];
}

-(void)dealloc {
	[_controllersSection0 release];
	[_controllersSection1 release];
	
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
	static NSString *cellID = @"SectionsSecondLevelCellID";
	
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	SettingsViewController *c = [[self sectionForIndex:section] objectAtIndex:row];
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
	}
	
	cell.textLabel.text = c.title;
	cell.imageView.image = c.image;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Table View Delegate Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	
	SettingsViewController *next = [[self sectionForIndex:section] objectAtIndex:row];
	
	[self.navigationController pushViewController:next animated:YES];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Custom Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// returns either controllersSection0 or 1, depending on the section-index
-(NSArray *) sectionForIndex:(NSInteger)index {
	if (index == 0) {
		return self.controllersSection0;
	} else {
		return self.controllersSection1;
	}
}

@end
