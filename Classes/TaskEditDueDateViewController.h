//
//  TaskEditDueDateViewController.h
//  Less2Do
//
//  Created by Matthias Tretter on 27.11.09.
//  Copyright 2009 BIAC. All rights reserved.
//

#import <UIKit/UIKit.h>

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Controller for editing the Due Date of a Task
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface TaskEditDueDateViewController : UIViewController {
	// datePicker to select the due-date
	UIDatePicker *datePicker;
	// label that shows the selected due-date
	UILabel *dateLabel;
	// the task which date is edited
	Task *task;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) Task *task;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)changeDate:(NSDate *)d;
- (IBAction)selectionChanged:(id)sender;

- (IBAction)setToday;
- (IBAction)setTomorrow;
- (IBAction)setNextWeek;
- (IBAction)setNone;

@end
