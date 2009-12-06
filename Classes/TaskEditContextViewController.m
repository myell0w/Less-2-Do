//
//  TaskEditContextViewController.m
//  Less2Do
//
//  Created by Matthias Tretter on 06.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import "TaskEditContextViewController.h"
#import "ContextDAO.h"


@implementation TaskEditContextViewController

@synthesize task;
@synthesize tableView;
@synthesize addContextControl;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSError *error;
	NSArray *objects = [ContextDAO allContexts:&error];
	
    contexts = [[NSMutableArray alloc] init];
	[contexts addObjectsFromArray:objects];	
	
	ALog("Contexts read: %@", contexts);
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
    }
	
    // Set up the cell...
	cell.textLabel.text = [[contexts objectAtIndex:row] description];
	cell.imageView.image = [UIImage imageNamed:@"all_tasks.png"];
	cell.accessoryType = [indexPath isEqual:lastIndexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
    return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//int newRow = [indexPath row];
    //int oldRow = (lastIndexPath != nil) ? [lastIndexPath row] : -1;
    
    if (![indexPath isEqual:lastIndexPath]) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath]; 
        oldCell.accessoryType = UITableViewCellAccessoryNone;
		
        lastIndexPath = indexPath;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
