//
//  TaskEditContextViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 06.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaskEditContextViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	// the table view to show
	UITableView *tableView;
	// the text-field for adding new Tags
	UITextField *addContextControl;
	// the Task to edit
	Task *task;
	// all contexts
	NSMutableArray *contexts;
	// the last selected context
	NSIndexPath *lastIndexPath;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITextField *addContextControl;
@property (nonatomic, retain) Task *task;

@end
