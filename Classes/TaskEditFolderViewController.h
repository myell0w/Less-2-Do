//
//  TaskEditFolderViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 06.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaskEditFolderViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	// the table view to show
	UITableView *tableView;
	// the text-field for adding new Tags
	UITextField *addFolderControl;
	// the Task to edit
	Task *task;
	// all folder
	NSMutableArray *folders;
	// the last selected context
	NSIndexPath *lastIndexPath;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITextField *addFolderControl;
@property (nonatomic, retain) Task *task;

@end
