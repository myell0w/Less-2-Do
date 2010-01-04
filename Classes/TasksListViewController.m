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
#import "ShowTaskViewController.h"


#define TITLE_LABEL_RECT  CGRectMake(47, 3, 190, 21)
#define TITLE_DETAIL_RECT CGRectMake(47,20,190,21)
#define COMPLETED_RECT    CGRectMake(6, 6, 32, 32)
#define STARRED_RECT	  CGRectMake(275, 6, 34, 34)
#define PRIORITY_RECT     CGRectMake(250,20,19,16)
#define RECURRENCE_RECT   CGRectMake(254,4,10,12)
#define FOLDER_COLOR_RECT CGRectMake(314,2,6,40)

#define TITLE_FONT_SIZE 15
#define TITLE_DETAIL_FONT_SIZE 11


@implementation TasksListViewController

@synthesize image;
@synthesize tasks;
@synthesize selector;
@synthesize argument;
@synthesize detailMode;
@synthesize currentPosition;

- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
		detailMode = TaskListDetailDateMode;
	}
	
	return self;
}

- (void)viewDidLoad {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	self.tasks = array;
	[array release];
		
	formatDate = [[NSDateFormatter alloc] init];
	[formatDate setDateFormat:@"EE, YYYY-MM-dd"];
	formatTime = [[NSDateFormatter alloc] init];
	[formatTime setDateFormat:@"h:mm a"];
}

- (void)viewWillAppear:(BOOL)animated {
	NSArray *objects = nil;
	
	objects = [self getTasks];
	
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
	self.argument = nil;
	
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
	[argument release];
	
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
	
	if (self.detailMode == TaskListDetailDateMode) {
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
	} else {
		NSString *distance = nil;
		Context* context = (Context *)t.context;
		
		if ([context hasGps]) {
			distance = [[NSString alloc] initWithFormat:@"distance: %f", [context distanceTo:currentPosition]];
		} else {
			distance = @"No GPS";
		}
	}

	
	UIView *folderColorView = (UIView *)[cell.contentView viewWithTag:TAG_FOLDER_COLOR];
	folderColorView.backgroundColor = t.folder != nil ? t.folder.color : [UIColor whiteColor];
	
	int priorityIdx = t.priority != nil ? [t.priority intValue] + 1 : -1;
	NSString *priorityName = [[NSString alloc] initWithFormat:@"priority_%d.png",priorityIdx];
	UIImageView *priorityView = (UIImageView *)[cell.contentView viewWithTag:TAG_PRIORITY];
	priorityView.image = [UIImage imageNamed:priorityName];
	[priorityName release];
	
	if (t.repeat != nil && ([t.repeat intValue]%100) != 0) {
		UIImageView *recurrenceView = (UIImageView *)[cell.contentView viewWithTag:TAG_RECURRENCE];
		recurrenceView.image = [UIImage imageNamed:@"recurrence.png"];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ShowTaskViewController *stvc = [[ShowTaskViewController alloc] 
										   initWithNibName:@"ShowTaskViewController" 
										   bundle:nil];
	stvc.title = @"Task Details";
	stvc.task = [self.tasks objectAtIndex:indexPath.row];
	
	[self.navigationController pushViewController:stvc animated:YES];
	[stvc release];
}

#pragma mark - 
#pragma mark Table View Data Source Methods 
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
										   forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row]; 
	NSError *error;
	
	Task *t = [(Task *)[self.tasks objectAtIndex:row] retain];
	[self.tasks removeObjectAtIndex:row]; 
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[BaseManagedObject deleteObject:t error:&error];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Custom Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (int)taskCount {
	//TODO: change, performance!
	NSArray *objects = [self getTasks];
	
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
	
	// init Recurrence-Image
	UIImageView *recurrenceView = [[UIImageView alloc] initWithFrame:RECURRENCE_RECT];
	recurrenceView.tag = TAG_RECURRENCE;
	[cell.contentView addSubview:recurrenceView];
	[recurrenceView release];
	
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
}

- (NSArray *)getTasks {
	// error object
	NSError *error = nil;
	// the result of the call
	NSArray *result = nil;
	// arguments begin with index 2 (0 and 1 are reserved)
	int argIdx = 2;
	
	if ([Task respondsToSelector:selector]) {
		// get method signature
		NSMethodSignature *signature = [[Task class] methodSignatureForSelector:selector];
		
		if (signature != nil) {
			// create invocation-object
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setTarget:[Task class]];
			[invocation setSelector:selector];
			
			// set arguments
			if (self.argument != nil) {
				[invocation setArgument:&argument atIndex:argIdx];
				argIdx++;
			}
			[invocation setArgument:&error atIndex:argIdx];
			
			// activate invocation
			[invocation retainArguments];
			[invocation invoke];
			[invocation getReturnValue:&result];
			
			ALog("Method with Signature %@ called to get Tasks", signature);
			
			return result;
		}
	} 
	
	return [Task getAllTasks:&error];
}

@end
