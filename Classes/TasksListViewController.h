//
//  TasksListViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 20.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Represents a Second-Level ViewController, that shows a list of Tasks (f.e. All Tasks)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum _TaskListDetailMode {
	TaskListDetailDateMode,
	TaskListDetailDistanceMode
} TaskListDetailMode;


@interface TasksListViewController : UITableViewController {
	// image that is shown in the table cell
	UIImage *image;
	// the tasks to show
	NSMutableArray *tasks;
	// date formatter for due-date
	NSDateFormatter *formatDate;
	// date formatter for due-time
	NSDateFormatter *formatTime;

	// flag to define what the detail-label should show
	TaskListDetailMode detailMode;
	// the current position
	CLLocationCoordinate2D currentPosition;
	// the method to call in the Task-Class
	SEL selector;
	// the optional argument for retrieving tasks from the Task-Class
	id argument;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSMutableArray *tasks;
@property (nonatomic) TaskListDetailMode detailMode;
@property (nonatomic) CLLocationCoordinate2D currentPosition;
@property (nonatomic) SEL selector;
@property (nonatomic, retain) id argument;

// returns the number of tasks shown in this TableView
- (int) taskCount;
// set Up a Cell
- (void)setUpCell:(UITableViewCell *)cell;
// value of either completed or starred was changed
- (IBAction)checkBoxValueChanged:(id)sender;

- (NSArray *)getTasks;
@end
