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
		lastIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
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
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contexts count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"ContextCellInTaskEdit";
	int row = [indexPath row];
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    }
	
    // Set up the cell...
	Context *context = (Context *)[contexts objectAtIndex:row];
	cell.textLabel.text = context.name;
	cell.imageView.image = [context hasGps] ? [UIImage imageNamed:@"context_gps.png"] : [UIImage imageNamed:@"context_no_gps.png"];
	cell.accessoryType = [indexPath isEqual:lastIndexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
    return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	Context *c = (Context *)[contexts objectAtIndex:row];
    
	[addContextControl resignFirstResponder];
	
    if (![indexPath isEqual:lastIndexPath]) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath]; 
        oldCell.accessoryType = UITableViewCellAccessoryNone;
		
        lastIndexPath = indexPath;		
		self.task.context = c;
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
	
	NSUInteger idx = [contexts indexOfObject:context];
	lastIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
	
	self.addContextControl.text = @"";
	[self.tableView reloadData];
}

@end
