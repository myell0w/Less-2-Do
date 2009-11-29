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
	
	//[ContextDAO addContextWithName:@"Gerhard" error:&error];
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
	
	self.tasks = array;
	[array release];
	
	NSArray *objects = [TaskDAO allTasks:&error];
	
	if (objects == nil) {
		NSLog(@"There was an error!");
		// Do whatever error handling is appropriate
	}
	if ([objects count] > 0)
	{
		// for schleife objekte erzeugen und array addObject:currentContext
		for (int i=0; i<[objects count]; i++) {
			Task *task = [objects objectAtIndex:i];
			[self.tasks addObject:task];
		}
	}
	
	/*
	// Den delegate vom Less2DoAppDelegate
	Less2DoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	// Den ManagedObjectContext durch den delegate
	NSManagedObjectContext *_context = [delegate managedObjectContext];
	// create a Task
	Task *t1 = (Task *)[NSEntityDescription 
					   insertNewObjectForEntityForName:@"Task" 
					   inManagedObjectContext:_context];
	Task *t2 = (Task *)[NSEntityDescription 
						insertNewObjectForEntityForName:@"Task" 
						inManagedObjectContext:_context];
	Task *t3 = (Task *)[NSEntityDescription 
						insertNewObjectForEntityForName:@"Task" 
						inManagedObjectContext:_context];
	Task *t4 = (Task *)[NSEntityDescription 
						insertNewObjectForEntityForName:@"Task" 
						inManagedObjectContext:_context];
	
	NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:t1,t2,t3,t4,nil];
	self.tasks = arr;
	[arr release];*/
}

- (void)viewDidUnload {
	self.image = nil;
	self.tasks = nil;
}

- (void)dealloc {
	[image release];
	[tasks release];
	
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
	
   
	UICheckBox *completedCB = (UICheckBox *)[cell.contentView viewWithTag:TAG_COMPLETED];
	[completedCB setOn:[t.isCompleted boolValue]];
	
	UICheckBox *starredCB = (UICheckBox *)[cell.contentView viewWithTag:TAG_STARRED];
	[starredCB setOn:[t.star boolValue]];
	
	UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:TAG_TITLE];
	titleLabel.text = t.name;
	
	// TODO: read out real data
	UILabel *titleDetail = (UILabel *)[cell.contentView viewWithTag:TAG_TITLE_DETAIL];
	titleDetail.text = @"due: We, 23.12.09, 2 pm";
	
	UIView *folderColorView = (UIView *)[cell.contentView viewWithTag:TAG_FOLDER_COLOR];
	folderColorView.backgroundColor = [UIColor redColor];
	
	int priorityIdx = [t.priority intValue] + 1;
	NSString *priorityName = [[NSString alloc] initWithFormat:@"priority_%d.png",priorityIdx];
	UIImageView *priorityView = (UIImageView *)[cell.contentView viewWithTag:TAG_PRIORITY];
	priorityView.image = [UIImage imageNamed:priorityName];
	[priorityName release];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Custom Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (int)taskCount {
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

// temporary store changed values in Dictionary (to keep old data stored in task)
- (IBAction)checkBoxValueChanged:(id)sender {
	UICheckBox *cb = (UICheckBox *)sender;
	
	NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:cb.tag];	
	NSNumber *value = [[NSNumber alloc] initWithBool:[cb isOn]];
	
	//[tempData setObject:value forKey:tagAsNum];	
	//ALog("Temporary Value stored in Dict: %@ = %@", tagAsNum, value);
	
	[tagAsNum release];
	[value release];
}


@end
