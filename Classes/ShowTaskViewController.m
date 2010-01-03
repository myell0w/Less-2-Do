//
//  ShowTaskViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 28.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "ShowTaskViewController.h"
#import "UICheckBox.h"

#define TITLE_LABEL_RECT  CGRectMake(47, 3, 180, 21)
#define TITLE_DETAIL_RECT CGRectMake(47,20,180,21)
#define COMPLETED_RECT    CGRectMake(6, 6, 32, 32)
#define STARRED_RECT	  CGRectMake(261, 6, 34, 34)
#define PRIORITY_RECT     CGRectMake(236,14,19,16)

#define IMAGE_RECT		  CGRectMake(12, 12, 20, 20)
#define TEXT_RECT		  CGRectMake(47, 10, 180, 24)
#define NOTES_RECT		  CGRectMake(47, 10, 250, 24)

#define TAG_IMAGE	30
#define TAG_TEXT	31

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
	
	
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
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
}

- (void)dealloc {
	[task release];
	[formatDate release];
	[formatTime release];
	[properties release];
	
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
	}
	
	else if ([reuseID isEqualToString:CELL_ID_FOLDER]) {
		UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:TAG_IMAGE];
		imageView.backgroundColor = task.folder != nil ? task.folder.color : [UIColor whiteColor];
		
		UILabel *textView = (UILabel *)[cell.contentView viewWithTag:TAG_TEXT];
		textView.text = [task.folder description];
	}
	
	else if ([reuseID isEqualToString:CELL_ID_CONTEXT]) {
		UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:TAG_IMAGE];
		imageView.image = [((Context *)task.context) hasGps] ? [UIImage imageNamed:@"context_gps.png"] : [UIImage imageNamed:@"context_no_gps.png"];
		
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



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
	textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	textLabel.lineBreakMode = UILineBreakModeWordWrap;
	// add Label to Cell
	[cell.contentView addSubview:textLabel];
	[textLabel release];
}

-(NSString *) cellIDForIndexPath:(NSIndexPath *)indexPath {
	/*int row = [indexPath row];
	int section = [indexPath section];
	
	if (section == 0 && row == 0)
		return CELL_ID_TITLE;
	else if (section == 0 && row == 1)
		return CELL_ID_FOLDER;
	else if (section == 0 && row == 2)
		return CELL_ID_CONTEXT;
	else if (section == 0 && row == 3)
		return CELL_ID_TAGS;
	
	else if (section == 0 && row == 4)
		return CELL_ID_NOTES;*/
	
	if (indexPath.row < [properties count]) {
		return [properties objectAtIndex:indexPath.row];
	}
		
	return nil;
}


@end

