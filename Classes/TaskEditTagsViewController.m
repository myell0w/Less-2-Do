//
//  TaskEditTagsViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 06.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "TaskEditTagsViewController.h"
#import "TagDAO.h"

#define FONT_SIZE 15

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
	[selectedTags addObjectsFromArray:[task.tags allObjects]];
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
		cell.textLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    }
	
    // Set up the cell...
	cell.textLabel.text = [[tags objectAtIndex:row] description];
	cell.imageView.image = [UIImage imageNamed:@"tag.png"];
	cell.accessoryType = ([selectedTags containsObject:[tags objectAtIndex:row]]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
    return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	UITableViewCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
	id tag = [tags objectAtIndex:row];
	
	[addTagControl resignFirstResponder];
    
	if ([selectedTags containsObject:tag]) {
		cell.accessoryType =  UITableViewCellAccessoryNone;
		[selectedTags removeObject:tag];
		[self.task removeTagsObject:tag];
	} else {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		[selectedTags addObject:tag];
		[self.task addTagsObject:tag];
	}

	ALog("Task.tags: %@", self.task.tags);
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (IBAction)addTag:(id)sender {
	[addTagControl resignFirstResponder];
	
	// Only Saves when text was entered
	if (addTagControl.text.length == 0)
		return;
	
	Tag *tag = (Tag *)[Tag objectOfType:@"Tag"];
	tag.name = addTagControl.text;
	ALog ("tag %@ inserted", tag);
	
	// add new tag to array + task
	[tags addObject:tag];
	[selectedTags addObject:tag];
	[self.task addTagsObject:tag];
	
	self.addTagControl.text = @"";
	[self.tableView reloadData];
}

@end

