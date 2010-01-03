//
//  ShowTaskViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 28.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"


@interface ShowTaskViewController : UITableViewController {
	// The Task to show
	Task *task;
	// Array of Properties set (only set properties are shown)
	NSMutableArray *properties;
	
	// date formatter for due-date
	NSDateFormatter *formatDate;
	// date formatter for due-time
	NSDateFormatter *formatTime;
	
	// footer view for start/stop
	UIView *footerView;
}

@property (nonatomic, retain) Task* task;

// value of either completed or starred was changed
- (IBAction)checkBoxValueChanged:(id)sender;
- (IBAction)startStopTask:(id)sender;


// returns the cellID for a given indexPath
- (NSString *) cellIDForIndexPath:(NSIndexPath *)indexPath;

// setUp-Functions for Cells
- (void)setUpTitleCell:(UITableViewCell *)cell;
- (void)setUpFolderContextTagsCell:(UITableViewCell *)cell;
- (void)setUpNotesCell:(UITableViewCell *)cell;

@end
