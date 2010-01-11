//
//  ShowTaskViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 28.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "ShowTaskViewController.h"
#import "EditTaskViewController.h"
#import "ShowContextViewController.h"
#import "UICheckBox.h"

#define TITLE_LABEL_RECT  CGRectMake(47, 3, 180, 21)
#define TITLE_DETAIL_RECT CGRectMake(47,20,180,21)
#define COMPLETED_RECT    CGRectMake(6, 6, 32, 32)
#define STARRED_RECT	  CGRectMake(261, 6, 34, 34)
#define PRIORITY_RECT     CGRectMake(238,20,19,16)
#define RECURRENCE_RECT   CGRectMake(242,4,10,12)

#define IMAGE_RECT		  CGRectMake(12, 12, 20, 20)
#define TEXT_RECT		  CGRectMake(47, 10, 180, 24)
#define NOTES_RECT		  CGRectMake(47, 13, 250, 24)

#define TAG_IMAGE	30
#define TAG_TEXT	31
#define TAG_TIMER   32

#define TITLE_FONT_SIZE 15
#define TITLE_DETAIL_FONT_SIZE 11



@implementation ShowTaskViewController

@synthesize task;



- (void)viewDidLoad {
	formatDate = [[NSDateFormatter alloc] init];
	[formatDate setDateFormat:@"EE, YYYY-MM-dd"];
	formatTime = [[NSDateFormatter alloc] init];
	[formatTime setDateFormat:@"h:mm a"];
	
	UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:@"Edit" 
															   style:UIBarButtonItemStylePlain
															  target:self 
															  action:@selector(edit:)];
	
	self.navigationItem.rightBarButtonItem = edit;
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(taskWasAdded:) 
												 name:@"TaskAddedNotification" object:nil];
		
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self reloadProperties];
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.task = nil;
	
	[formatDate release];
	formatDate = nil;
	[formatTime release];
	formatTime = nil;
	[properties release];
	properties = nil;
	[footerView release];
	footerView = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
	[task release];
	[formatDate release];
	[formatTime release];
	[properties release];
	[footerView release];
	
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [properties count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
	NSString *reuseID = nil;
	
	reuseID = [self cellIDForIndexPath:indexPath];	
	cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseID];
	
    if (cell == nil) {
		// Init Title-Cell
		if ([reuseID isEqualToString:CELL_ID_TITLE]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID] autorelease];
			[self setUpTitleCell:cell];
		} 
		
		// Init-Folder-Cell
		else if ([reuseID isEqualToString:CELL_ID_FOLDER]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID] autorelease];
			[self setUpFolderContextTagsCell:cell];
		}
		
		// Init-Context-Cell
		else if ([reuseID isEqualToString:CELL_ID_CONTEXT]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID] autorelease];
			[self setUpFolderContextTagsCell:cell];
		}
		
		// Init-Tags-Cell
		else if ([reuseID isEqualToString:CELL_ID_TAGS]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID] autorelease];
			[self setUpFolderContextTagsCell:cell];
		}
		
		// Init-Notes-Cell
		else if ([reuseID isEqualToString:CELL_ID_NOTES]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID] autorelease];
			[self setUpNotesCell:cell];
		}
		
		// set font
		cell.textLabel.font = cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:NORMAL_FONT_SIZE];
    }
    
    // Set up the cell-values ...
	
	if ([reuseID isEqualToString:CELL_ID_TITLE]) {
		UICheckBox *completedCB = (UICheckBox *)[cell.contentView viewWithTag:TAG_COMPLETED];
		[completedCB setOn:task.isCompleted != nil ? [task.isCompleted boolValue] : NO];
		
		UICheckBox *starredCB = (UICheckBox *)[cell.contentView viewWithTag:TAG_STARRED];
		[starredCB setOn:task.star != nil ? [task.star boolValue] : NO];
		
		UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:TAG_TITLE];
		if (task.name != nil) {
			titleLabel.text = task.name;
		} else {
			titleLabel.text = @"(No Title)";
		}
		
		UILabel *titleDetail = (UILabel *)[cell.contentView viewWithTag:TAG_TITLE_DETAIL];
		NSString *dueDateAndTime = nil;
		if (task.dueDate != nil) {
			dueDateAndTime = [[NSString alloc] initWithFormat:@"due: %@, %@",
							  [formatDate stringFromDate:task.dueDate],
							  task.dueTime != nil ? [formatTime stringFromDate:task.dueTime] : @"no time"];
		} else {
			dueDateAndTime = @"no due date";
		}
		
		titleDetail.text = dueDateAndTime;
		[dueDateAndTime release];
		
		int priorityIdx = task.priority != nil ? [task.priority intValue] + 1 : -1;
		NSString *priorityName = [[NSString alloc] initWithFormat:@"priority_%d.png",priorityIdx];
		UIImageView *priorityView = (UIImageView *)[cell.contentView viewWithTag:TAG_PRIORITY];
		priorityView.image = [UIImage imageNamed:priorityName];
		[priorityName release];
		
		if (task.repeat != nil && ([task.repeat intValue]%100) != 0) {
			UIImageView *recurrenceView = (UIImageView *)[cell.contentView viewWithTag:TAG_RECURRENCE];
			recurrenceView.image = [UIImage imageNamed:@"recurrence.png"];
		}
	}
	
	else if ([reuseID isEqualToString:CELL_ID_FOLDER]) {
		UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:TAG_IMAGE];
		imageView.backgroundColor = task.folder != nil ? task.folder.color : [UIColor whiteColor];
		
		UILabel *textView = (UILabel *)[cell.contentView viewWithTag:TAG_TEXT];
		textView.text = [task.folder description];
	}
	
	else if ([reuseID isEqualToString:CELL_ID_CONTEXT]) {
		Context *context = (Context *)task.context;
		UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:TAG_IMAGE];
		imageView.image = [context hasGps] ? [UIImage imageNamed:@"context_gps.png"] : [UIImage imageNamed:@"context_no_gps.png"];
		cell.accessoryType = [context hasGps] ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryNone;
		
		UILabel *textView = (UILabel *)[cell.contentView viewWithTag:TAG_TEXT];
		textView.text = [task.context description];
	}
	
	else if ([reuseID isEqualToString:CELL_ID_TAGS]) {
		UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:TAG_IMAGE];
		imageView.image = [UIImage imageNamed:@"tag.png"];
		
		UILabel *textView = (UILabel *)[cell.contentView viewWithTag:TAG_TEXT];
		textView.text = [task tagsDescription];
	}
	
	else if ([reuseID isEqualToString:CELL_ID_NOTES]) {
		if (self.task.note && [self.task.note length] > 0) {
			UILabel *notesLabel = (UILabel *)[cell.contentView viewWithTag:TAG_NOTES];
			[notesLabel setNumberOfLines:0];
			notesLabel.text = self.task.note;
			[notesLabel sizeToFit];
		}
	}
	
	
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSString *cellID = [self cellIDForIndexPath:indexPath];
	
	// No rows can't be selected
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat		result = 44.0f;
	NSString*	text = nil;
	CGFloat		width = 0;
	CGFloat		tableViewWidth;
	CGRect		bounds = [UIScreen mainScreen].bounds;
	
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
		tableViewWidth = bounds.size.width;
	else
		tableViewWidth = bounds.size.height;
	
	width = tableViewWidth - 110;		// fudge factor
	text = self.task.note;
	
	if (text && [[self cellIDForIndexPath:indexPath] isEqualToString:CELL_ID_NOTES]) {
		// The notes can be of any height
		// This needs to work for both portrait and landscape orientations.
		// Calls to the table view to get the current cell and the rect for the 
		// current row are recursive and call back this method.
		CGSize		textSize = { width, 20000.0f };		// width and height of text area
		CGSize		size = [text sizeWithFont:[UIFont systemFontOfSize:NORMAL_FONT_SIZE]
						constrainedToSize:textSize 
							lineBreakMode:UILineBreakModeWordWrap];
		
		size.height += 29.0f;			// top and bottom margin
		result = MAX(size.height, 44.0f);	// at least one row
	}
	
	return result;
}

// specify the height of your footer section
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //differ between your sections or if you
    //have only on section return a static value
    return 50;
}

// custom view for footer. will be adjusted to default or specified footer height
// Notice: this will work only for one section within the table view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
    if(footerView == nil) {
		int value = [self.task.timerValue intValue];
		int seconds = value % 60;
		int minutes = value / 60;
		int hours =  value / 3600;
		NSString *s = [[NSString alloc] initWithFormat:@"Time: %02d:%02d:%02d h", hours, minutes, seconds];

        //allocate the view if it doesn't exist yet
        footerView  = [[UIView alloc] init];
		
        //we would like to show a gloosy red button, so get the image first
        UIImage *image = [[UIImage imageNamed:@"button_start.png"]
						  stretchableImageWithLeftCapWidth:8 topCapHeight:8];
		
        //create the button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setBackgroundImage:image forState:UIControlStateNormal];
		
        //the button should be as big as a table view cell
        [button setFrame:CGRectMake(10, 15, 100, 44)];
		
        //set title, font size and font color
        [button setTitle:@"Start" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		
        //set action of the button
        [button addTarget:self action:@selector(startStopTask:) forControlEvents:UIControlEventTouchUpInside];
		
        //add the button to the view
        [footerView addSubview:button];
	
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(130, 16, 178, 42)];
		label.font = [UIFont boldSystemFontOfSize:NORMAL_FONT_SIZE];
		label.tag = TAG_TIMER;
		label.textAlignment = UITextAlignmentCenter;
		label.text = s;
		
		[footerView addSubview:label];
		[label release];
		[s release];
    }
	
    //return the view for the footer
    return footerView;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	ShowContextViewController *scvc = [[ShowContextViewController alloc] 
									initWithNibName:@"ShowContextViewController" 
									bundle:nil];
	scvc.title = [self.task.context description];
	scvc.context = (Context *)self.task.context;
	
	[self.navigationController pushViewController:scvc animated:YES];
	[scvc release];
}



// save changed value immediately (completed/starred)
- (IBAction)checkBoxValueChanged:(id)sender {
	// get the sender-control
	UICheckBox *cb = (UICheckBox *)sender;
		
	switch (cb.tag) {
		case TAG_STARRED:
			task.star = [[NSNumber alloc] initWithBool:[cb isOn]];
			break;
		case TAG_COMPLETED:
			task.isCompleted = [[NSNumber alloc] initWithBool:[cb isOn]];
			if ([cb isOn]) {
				task.completionDate = [[NSDate alloc] init];
			}
			break;
	}
}

- (void) setUpTitleCell:(UITableViewCell *)cell {
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
	
}

- (void)setUpFolderContextTagsCell:(UITableViewCell *)cell {
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:IMAGE_RECT];
	imageView.tag = TAG_IMAGE;
	[cell.contentView addSubview:imageView];
	[imageView release];
	
	UILabel *textLabel = [[UILabel alloc] initWithFrame:TEXT_RECT];
	textLabel.font = [UIFont boldSystemFontOfSize:NORMAL_FONT_SIZE];
	textLabel.tag = TAG_TEXT;
	// add Label to Cell
	[cell.contentView addSubview:textLabel];
	[textLabel release];
}

- (void)setUpNotesCell:(UITableViewCell *)cell {
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:IMAGE_RECT];
	imageView.tag = TAG_IMAGE;
	imageView.image = [UIImage imageNamed:@"notes.png"];
	[cell.contentView addSubview:imageView];
	[imageView release];
	
	UILabel *textLabel = [[UILabel alloc] initWithFrame:NOTES_RECT];
	textLabel.font = [UIFont boldSystemFontOfSize:NORMAL_FONT_SIZE];
	textLabel.tag = TAG_NOTES;
	textLabel.lineBreakMode = UILineBreakModeWordWrap;
	// add Label to Cell
	[cell.contentView addSubview:textLabel];
	[textLabel release];
}

-(NSString *) cellIDForIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [properties count]) {
		return [properties objectAtIndex:indexPath.row];
	}
		
	return nil;
}

- (IBAction)startStopTask:(id)sender {
	UIButton *button = (UIButton *)sender;
	
	// Start?
	if ([[button titleForState:UIControlStateNormal] isEqualToString:@"Start"]) {
		// make button red and change label
        UIImage *image = [[UIImage imageNamed:@"button_stop.png"]
						  stretchableImageWithLeftCapWidth:8 topCapHeight:8];
		
		[button setTitle:@"Stop" forState:UIControlStateNormal];
        [button setBackgroundImage:image forState:UIControlStateNormal];
		
		timer = [NSTimer scheduledTimerWithTimeInterval:1.0
												 target:self
											   selector:@selector(increaseTimer:)
											   userInfo:nil
												repeats:YES];
		
	} 
	
	// Stop
	else {
		// make button green and change label
        UIImage *image = [[UIImage imageNamed:@"button_start.png"]
						  stretchableImageWithLeftCapWidth:8 topCapHeight:8];
		
		[button setTitle:@"Start" forState:UIControlStateNormal];
        [button setBackgroundImage:image forState:UIControlStateNormal];
		
		[timer invalidate];
	}
}


- (IBAction)edit:(id)sender {
	EditTaskViewController *etvc = [[EditTaskViewController alloc] 
									initWithNibName:@"EditTaskViewController" 
									bundle:nil];
	etvc.title = @"Edit Task";
	etvc.task = self.task;
	etvc.mode = TaskControllerEditMode;
	
	[self.navigationController pushViewController:etvc animated:YES];
	[etvc release];
}

- (IBAction)taskWasAdded:(NSNotification *)notification {
	[self reloadProperties];
	[self.tableView reloadData];
}

- (IBAction)increaseTimer:(NSTimer *) theTimer {
	int value = [self.task.timerValue intValue] + 1;
	NSNumber* newNumber = [[NSNumber alloc] initWithInt:value];
	int seconds = value % 60;
	int minutes = value / 60;
	int hours =  value / 3600;
	UILabel *label = (UILabel *)[footerView viewWithTag:TAG_TIMER];
	NSString *s = [[NSString alloc] initWithFormat:@"Time: %02d:%02d:%02d h", hours, minutes, seconds];
	
	self.task.timerValue = newNumber;
	label.text = s;
	
	[newNumber release];
	[s release];
}

- (void)reloadProperties {
	[properties release];
	properties = [[NSMutableArray alloc] init];
	
	[properties addObject:CELL_ID_TITLE];
	
	if (self.task.folder != nil)
		[properties addObject:CELL_ID_FOLDER];
	
	if (self.task.context != nil)
		[properties addObject:CELL_ID_CONTEXT];
	
	if (self.task.tags != nil && [self.task.tags count] > 0)
		[properties addObject:CELL_ID_TAGS];
	
	if (self.task.note != nil && [self.task.note length] > 0)
		[properties addObject:CELL_ID_NOTES];
	
}

@end

