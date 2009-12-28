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
	Task *task;
	// date formatter for due-date
	NSDateFormatter *formatDate;
	// date formatter for due-time
	NSDateFormatter *formatTime;
	
}

@property (nonatomic, retain) Task* task;

// returns the cellID for a given indexPath
- (NSString *) cellIDForIndexPath:(NSIndexPath *)indexPath;
// value of either completed or starred was changed
- (IBAction)checkBoxValueChanged:(id)sender;

// setUp-Functions for Cells
- (void)setUpTitleCell:(UITableViewCell *)cell;
- (void)setUpFolderContextTagsCell:(UITableViewCell *)cell;

@end
