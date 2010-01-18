//
//  TaskEditContextViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 06.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "TaskEditContextViewController.h"
#import "Context.h"

#define FONT_SIZE 15


@implementation TaskEditContextViewController

@synthesize task;
@synthesize tableView;
@synthesize addContextControl;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSError *error;
	NSArray *objects = [Context getAllContexts:&error];
	
    contexts = [[NSMutableArray alloc] init];
	[contexts addObjectsFromArray:objects];	
	
	ALog("Contexts read: %@", contexts);
}



- (void)viewWillAppear:(BOOL)animated {
	// pre-check row if task has context set
	if (self.task.context != nil) {
		NSUInteger idx = [contexts indexOfObject:self.task.context];
		lastIndexPath = [NSIndexPath indexPathForRow:idx inSection:1];
	} else {
		lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	}

		
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
	self.addContextControl = nil;
	self.task = nil;
	
	[contexts release];
	contexts = nil;
	
	[lastIndexPath release];
	lastIndexPath = nil;
}

- (void)dealloc {
	[tableView release];
	[task release];
	[addContextControl release];
	[contexts release];
	[lastIndexPath release];
	
    [super dealloc];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return 1;
	
    return [contexts count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"ContextCellInTaskEdit";
    static NSString *cellIDNoContext = @"ContextCellInTaskEditNoContext";
	
    UITableViewCell *cell = nil;
	
	if (indexPath.section == 0) {
		cell = [aTableView dequeueReusableCellWithIdentifier:cellIDNoContext];
	} else {
		cell = [aTableView dequeueReusableCellWithIdentifier:cellID];
	}

	
    if (cell == nil) {
		if (indexPath.section == 0) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDNoContext] autorelease];
		} else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
		}

		cell.textLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    }
	
    // Set up the cell...
	if (indexPath.section == 0) {
		cell.textLabel.text = @"No Context";
		cell.imageView.image = [UIImage imageNamed:@"no_context.png"];
		cell.accessoryType = [indexPath isEqual:lastIndexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	} else {
		Context *context = (Context *)[contexts objectAtIndex:indexPath.row];
		cell.textLabel.text = context.name;
		cell.imageView.image = [context hasGps] ? [UIImage imageNamed:@"context_gps.png"] : [UIImage imageNamed:@"context_no_gps.png"];
		cell.accessoryType = [indexPath isEqual:lastIndexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		[addContextControl resignFirstResponder];
		
		if (![indexPath isEqual:lastIndexPath]) {
			UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
			newCell.accessoryType = UITableViewCellAccessoryCheckmark;
			
			UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath]; 
			oldCell.accessoryType = UITableViewCellAccessoryNone;
			
			lastIndexPath = indexPath;		
			self.task.context = nil;
		}
	} else {
		Context *c = (Context *)[contexts objectAtIndex:indexPath.row];
		
		[addContextControl resignFirstResponder];
		
		if (![indexPath isEqual:lastIndexPath]) {
			UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
			newCell.accessoryType = UITableViewCellAccessoryCheckmark;
			
			UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath]; 
			oldCell.accessoryType = UITableViewCellAccessoryNone;
			
			lastIndexPath = indexPath;		
			self.task.context = c;
			
			if(c.tasks == nil) {
				ALog ("Init new Set for Context-Task");
				[c addTasks:[NSSet setWithObject:self.task]];
			}
			else {
				ALog ("Set exists, added Task");
				[c addTasksObject:self.task];
			}
		}
	}
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)addContext:(id)sender {
	[addContextControl resignFirstResponder];
	
	// Only Saves when text was entered
	if (self.addContextControl.text.length == 0)
		return;
	
	Context *context = (Context *)[Context objectOfType:@"Context"];
	context.name = addContextControl.text;
	ALog ("context %@ inserted", context);
	
	[contexts addObject:context];
	self.task.context = context;
	if(context.tasks == nil) {
		ALog ("Init new Set for Context-Task");
		[context addTasks:[NSSet setWithObject:self.task]];
	}
	else {
		ALog ("Set exists, added Task");
		[context addTasksObject:self.task];
	}
	
	
	NSUInteger idx = [contexts indexOfObject:context];
	lastIndexPath = [NSIndexPath indexPathForRow:idx inSection:1];
	
	self.addContextControl.text = @"";
	[self.tableView reloadData];
}

@end
