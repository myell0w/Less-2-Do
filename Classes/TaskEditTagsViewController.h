//
//  TaskEditTagsViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 06.12.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Detail Controller for editing the Tags of a Task
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface TaskEditTagsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	// the table view to show
	UITableView *tableView;
	// the text-field for adding new Tags
	UITextField *addTagControl;
	// the Task to edit
	Task *task;
	// all tags
	NSMutableArray *tags;
	// the selected tags
	NSMutableArray *selectedTags;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITextField *addTagControl;
@property (nonatomic, retain) Task *task;

@end
