//
//  SecondLevelViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 20.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "TasksListViewController.h"
#import "UICheckBox.h"
#import "Less2DoAppDelegate.h"
#import "TaskDAO.h"

#define TITLE_LABEL_RECT  CGRectMake(47, 3, 190, 21)
#define TITLE_DETAIL_RECT CGRectMake(47,20,190,21)
#define COMPLETED_RECT    CGRectMake(6, 6, 32, 32)
#define STARRED_RECT	  CGRectMake(275, 6, 34, 34)
#define PRIORITY_RECT     CGRectMake(250,14,19,16)
#define FOLDER_COLOR_RECT CGRectMake(314,2,6,40)

#define TITLE_FONT_SIZE 15
#define TITLE_DETAIL_FONT_SIZE 11

#define TAG_TITLE		 1
#define TAG_TITLE_DETAIL 2
#define TAG_COMPLETED	 3
#define TAG_STARRED		 4
#define TAG_PRIORITY	 5
#define TAG_FOLDER_COLOR 6

@implementation TasksListViewController

@synthesize image;
@synthesize tasks;


- (void)viewDidLoad {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSError *error;
	
	self.tasks = array;
	[array release];
	
	NSArray *objects = [TaskDAO allTasks:&error];
	
	if (objects == nil) {
		ALog(@"There was an error!");
		// Do whatever error handling is appropriate
	}
	else {
		// for schleife objekte erzeugen und array addObject:current Task
		for (Task *t in objects) {
			[self.tasks addObject:t];
		}
	}
	
	formatDate = [[NSDateFormatter alloc] init];
	[formatDate setDateFormat:@"EE, YYYY-MM-dd"];
	formatTime = [[NSDateFormatter alloc] init];
	[formatTime setDateFormat:@"h:mm a"];
}

- (void)viewWillAppear:(BOOL)animated {
	//TODO: delete, only for MR2
	NSError *error;
	NSArray *objects = [TaskDAO allTasks:&error];
	
	if (objects == nil) {
		ALog(@"There was an error!");
		// Do whatever error handling is appropriate
	}
	else {
		[self.tasks removeAllObjects];
		// for schleife objekte erzeugen und array addObject:current Task
		for (Task *t in objects) {
			[self.tasks addObject:t];
		}
	}
	
	
	[self.tableView reloadData];
	[super viewWillAppear:animated];
}

- (void)viewDidUnload {
	self.image = nil;
	self.tasks = nil;
	
	[formatDate release];
	formatDate = nil;
	[formatTime release];
	formatTime = nil;
}

- (void)dealloc {
	[image release];
	[tasks release];
	[formatDate release];
	[formatTime release];
	
	[super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	//TODO:change
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [tasks count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *reuseID = @"TaskInListCellID";
	UITableViewCell *cell = nil;
	int row = [indexPath row];
	Task *t = [tasks objectAtIndex:row];
	
	cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseID];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID] autorelease];
		[self setUpCell:cell];
	}
	
	// set up values:
   
	UICheckBox *completedCB = (UICheckBox *)[cell.contentView viewWithTag:TAG_COMPLETED];
	[completedCB setOn:t.isCompleted != nil ? [t.isCompleted boolValue] : NO];
		
	UICheckBox *starredCB = (UICheckBox *)[cell.contentView viewWithTag:TAG_STARRED];
	[starredCB setOn:t.star != nil ? [t.star boolValue] : NO];
	
	UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:TAG_TITLE];
	if (t.name != nil) {
		titleLabel.text = t.name;
	} else {
		titleLabel.text = @"(No Title)";
	}
	
	UILabel *titleDetail = (UILabel *)[cell.contentView viewWithTag:TAG_TITLE_DETAIL];
	NSString *dueDateAndTime = nil;
	if (t.dueDate != nil) {
		dueDateAndTime = [[NSString alloc] initWithFormat:@"due: %@, %@",
						  [formatDate stringFromDate:t.dueDate],
						  t.dueTime != nil ? [formatTime stringFromDate:t.dueTime] : @"no time"];
	} else {
		dueDateAndTime = @"no due date";
	}

	titleDetail.text = dueDateAndTime;
	[dueDateAndTime release];
	
	// TODO: read out real data
	UIView *folderColorView = (UIView *)[cell.contentView viewWithTag:TAG_FOLDER_COLOR];
	folderColorView.backgroundColor = t.folder != nil ? t.folder.color : [UIColor whiteColor];
	
	int priorityIdx = t.priority != nil ? [t.priority intValue] + 1 : -1;
	NSString *priorityName = [[NSString alloc] initWithFormat:@"priority_%d.png",priorityIdx];
	UIImageView *priorityView = (UIImageView *)[cell.contentView viewWithTag:TAG_PRIORITY];
	priorityView.image = [UIImage imageNamed:priorityName];
	[priorityName release];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ALog("selected row: %@", indexPath);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Custom Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (int)taskCount {
	//TODO: delete, only for MR2
	NSError *error;
	NSArray *objects = [TaskDAO allTasks:&error];
	
	if (objects == nil) {
		ALog(@"There was an error!");
		// Do whatever error handling is appropriate
	}
	else {
		[self.tasks removeAllObjects];
		// for schleife objekte erzeugen und array addObject:current Task
		for (Task *t in objects) {
			[self.tasks addObject:t];
		}
	}
	
	
	[self.tableView reloadData];
	return [tasks count];
}

- (void)setUpCell:(UITableViewCell *)cell {
	// init Label for Detail-Text
	UILabel *titleDetail = [[UILabel alloc] initWithFrame:TITLE_DETAIL_RECT];
	titleDetail.font = [UIFont boldSystemFontOfSize:TITLE_DETAIL_FONT_SIZE];
	titleDetail.tag = TAG_TITLE_DETAIL;
	// add Label to Cell
	[cell.contentView addSubview:titleDetail];
	[titleDetail release];
	
	// init Label for Title
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:TITLE_LABEL_RECT];
	titleLabel.font = [UIFont boldSystemFontOfSize:TITLE_FONT_SIZE];
	titleLabel.tag = TAG_TITLE;
	// add Label to Cell
	[cell.contentView addSubview:titleLabel];
	[titleLabel release];

	
	// init Completed-Checkbox
	UICheckBox *completedCB = [[UICheckBox alloc] initWithFrame:COMPLETED_RECT];
	completedCB.tag = TAG_COMPLETED;
	[completedCB addTarget:self 
					action:@selector(checkBoxValueChanged:) 
		  forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:completedCB];
	[completedCB release];
	
	
	// init Starred-Checkbox
	UICheckBox *starredCB = [[UICheckBox alloc] initWithFrame:STARRED_RECT 
												   andOnImage:@"star_on.png" 
												  andOffImage:@"star_off.png"];
	starredCB.tag = TAG_STARRED;
	[starredCB addTarget:self 
				  action:@selector(checkBoxValueChanged:) 
		forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:starredCB];
	[starredCB release];
	
	// init Priority-Image
	UIImageView *priorityView = [[UIImageView alloc] initWithFrame:PRIORITY_RECT];
	priorityView.tag = TAG_PRIORITY;
	[cell.contentView addSubview:priorityView];
	[priorityView release];
	
	// init Folder-Color-View
	UIView *folderColorView = [[UIView alloc] initWithFrame:FOLDER_COLOR_RECT];
	folderColorView.tag = TAG_FOLDER_COLOR;
	[cell.contentView addSubview:folderColorView];
	[folderColorView release];
}

// save changed value immediately (completed/starred)
- (IBAction)checkBoxValueChanged:(id)sender {
	// get the sender-control
	UICheckBox *cb = (UICheckBox *)sender;
	// the cell in which the sender is located (2x superview, because: cell - contentView - checkbox)
	UITableViewCell *cell = (UITableViewCell *)[[cb superview] superview];
	// the row index of the cell
	NSUInteger buttonRow = [[self.tableView indexPathForCell:cell] row];
	
	Task *t = [tasks objectAtIndex:buttonRow];
	
	switch (cb.tag) {
		case TAG_STARRED:
			t.star = [[NSNumber alloc] initWithBool:[cb isOn]];
			break;
		case TAG_COMPLETED:
			t.isCompleted = [[NSNumber alloc] initWithBool:[cb isOn]];
			if ([cb isOn]) {
				t.completionDate = [[NSDate alloc] init];
			}
			break;
	}
	
	ALog("New Task: %@", t);
}


@end
