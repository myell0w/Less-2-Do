//
//  TaskEditTagsViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 06.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "TaskEditTagsViewController.h"
#import "TagDAO.h"


@implementation TaskEditTagsViewController

@synthesize tableView;
@synthesize task;
@synthesize addTagControl;



- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSError *error;
	NSArray *objects = [TagDAO allTags:&error];

    tags = [[NSMutableArray alloc] init];
	[tags addObjectsFromArray:objects];	
	
	ALog("Tags read: %@", tags);
	
	selectedTags = [[NSMutableArray alloc] init];
	//TODO: init with tags of Task
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.tableView = nil;
	self.addTagControl = nil;
	self.task = nil;
	
	[tags release];
	tags = nil;
	
	[selectedTags release];
	selectedTags = nil;
}

- (void)dealloc {
	[tableView release];
	[task release];
	[addTagControl release];
	[tags release];
	[selectedTags release];
	
    [super dealloc];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tags count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"TagCellInTaskEdit";
	int row = [indexPath row];
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
	
    // Set up the cell...
	cell.textLabel.text = [[tags objectAtIndex:row] description];
	cell.imageView.image = [UIImage imageNamed:@"all_tasks.png"];
	cell.accessoryType = ([selectedTags containsObject:[tags objectAtIndex:row]]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
    return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	UITableViewCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
	id tag = [tags objectAtIndex:row];
    
	//TODO: bedingung einfügen
	if ([selectedTags containsObject:tag]) {
		cell.accessoryType =  UITableViewCellAccessoryNone;
		[selectedTags removeObject:tag];
	} else {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		[selectedTags addObject:tag];
	}
	
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end

