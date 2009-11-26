//
//  EditTaskViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 26.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_ID_TITLE @"TaskTitleCell"
#define CELL_ID_PRIORITY @"TaskPriorityCell"
#define CELL_ID_DUEDATE @"CellIDDueDate"
#define CELL_ID_DUETIME @"CellIDDueTime"

@interface EditTaskViewController : UITableViewController {
	Task *task;
}

@property (nonatomic, retain) Task *task;

-(NSString *) cellIDForIndexPath:(NSIndexPath *)indexPath;

@end
