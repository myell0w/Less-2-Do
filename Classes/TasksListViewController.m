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
@synthesize filteredTasks;
@synthesize searchDisplayController;
@synthesize selector;
@synthesize argument;
@synthesize detailMode;
@synthesize currentPosition;
@synthesize parent;

- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
		detailMode = TaskListDetailDateMode;
	}
	
	return self;
}

- (void)viewDidLoad {
	ALog ("viewDidLoad of TasksListViewController");
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
	self.tasks = array;
	self.filteredTasks = filteredArray;
	[array release];
	[filteredArray release];
		
	formatDate = [[NSDateFormatter alloc] init];
	[formatDate setDateFormat:@"EE, yyyy-MM-dd"];
	formatTime = [[NSDateFormatter alloc] init];
	[formatTime setDateFormat:@"h:mm a"];
	
	self.tableView.scrollEnabled = YES;
	
	// init searchDisplayController
	UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 41.0)];
	self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	self.searchDisplayController.delegate = self;
	self.searchDisplayController.searchResultsDataSource = self;
	self.searchDisplayController.searchResultsDelegate = self;
	[searchBar release];
	self.tableView.tableHeaderView = self.searchDisplayController.searchBar;
	
	// scroll down to hide searchbar
	self.tableView.contentOffset = CGPointMake(0., 44.);
}

- (void)viewWillAppear:(BOOL)animated {
	ALog ("viewWillAppear of TasksListViewController");
	[self loadData];	
	[super viewWillAppear:animated];
}

- (void)viewDidUnload {
	self.image = nil;
	self.tasks = nil;
	self.filteredTasks = nil;
	self.argument = nil;
	self.searchDisplayController = nil;
	self.parent = nil;
	
	[formatDate release];
	formatDate = nil;
	[formatTime release];
	formatTime = nil;
}

- (void)dealloc {
	[image release];
	[tasks release];
	[filteredTasks release];
	[searchDisplayController release];
	[formatDate release];
	[formatTime release];
	[argument release];
	[parent release];
	
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
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if (aTableView == self.searchDisplayController.searchResultsTableView) {
		return [self.filteredTasks count];
	}
	
	return [tasks count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *reuseID = @"TaskInListCellID";
	UITableViewCell *cell = nil;
	int row = [indexPath row];
	Task *t = nil;
	
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		t = [filteredTasks objectAtIndex:row];
	} else {
		t = [tasks objectAtIndex:row];
	}
	
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
							  [formatDate stringFromDate:[t nextDueDate]],
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
			double distanceDouble = [context distanceTo:currentPosition];
			if(distanceDouble>1000)
				distance = [[NSString alloc] initWithFormat:@"distance: %.2f km", distanceDouble/1000];
			else {
				distance = [[NSString alloc] initWithFormat:@"distance: %.0f m", distanceDouble];
			}

			titleDetail.text = distance;
			[distance release];
		} else {
			distance = @"No GPS";
			titleDetail.text = distance;
		}
	}

	
	UIView *folderColorView = (UIView *)[cell.contentView viewWithTag:TAG_FOLDER_COLOR];
	folderColorView.backgroundColor = t.folder != nil ? t.folder.color : [UIColor whiteColor];
	
	int priorityIdx = t.priority != nil ? [t.priority intValue] + 1 : -1;
	NSString *priorityName = [[NSString alloc] initWithFormat:@"priority_%d.png",priorityIdx];
	UIImageView *priorityView = (UIImageView *)[cell.contentView viewWithTag:TAG_PRIORITY];
	priorityView.image = [UIImage imageNamed:priorityName];
	[priorityName release];
	
	if ([t isRepeating]) {
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
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		stvc.task = [self.filteredTasks objectAtIndex:indexPath.row];
	} else {
		stvc.task = [self.tasks objectAtIndex:indexPath.row];
	}
	if(self.parent == nil)
		[self.navigationController pushViewController:stvc animated:YES];
	else
		[self.parent.navigationController pushViewController:stvc animated:YES];
	[stvc release];
}

#pragma mark - 
#pragma mark Table View Data Source Methods 
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
										   forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row]; 
	NSError *error;
	
	Task *t = (Task *)[self.tasks objectAtIndex:row];

	//Remove Folder
	Folder *f = t.folder;
	if (f != nil)
		[f removeTasksObject:t];
	t.folder = nil;
	
	//Remove Context
	Context *c = t.context;
	if (c != nil)
		[c removeTasksObject:t];
	t.context = nil;

	//Remove Tags
	NSMutableArray *tagsToRemove = [NSMutableArray array];
	for(Tag *tag in t.tags)
	{
		[tagsToRemove addObject:tag];
	}
	for(Tag *tag in tagsToRemove)
	{
		[tag removeTasksObject:t];
	}
	[t removeTags:[NSSet setWithArray:tagsToRemove]];
	
	
	[Task deleteObject:t error:&error];
	[BaseManagedObject commit];
	
	[self.tasks removeObjectAtIndex:row]; 
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	//self.tableView.contentOffset = CGPointMake(0., 44.);
	
	ALog(@"Task gelöscht");
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Content Filtering
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	// Update the filtered array based on the search text
	
	[self.filteredTasks removeAllObjects]; // First clear the filtered array.
	
	// Search the main list

	for (Task *t in self.tasks) {
		NSRange range = [t.name rangeOfString:searchText options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
		
		if (range.location != NSNotFound) {
			[self.filteredTasks addObject:t];
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:nil];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Custom Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadData {
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
}

- (int)taskCount {
	//TODO: change, performance!
	NSArray *objects = [self getTasks];
	return [objects count];
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

	ALog("Method getAllTasks called");
	
	return [Task getAllTasks:&error];
}

@end
